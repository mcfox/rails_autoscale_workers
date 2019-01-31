# == Schema Information
#
# Table name: work_managers
#
#  id                     :integer          not null, primary key
#  name                   :string
#  aws_region             :string
#  autoscalinggroup_name  :string
#  queue_name             :string
#  max_workers            :integer
#  min_workers            :integer
#  minutes_to_process     :integer
#  jobs_per_cycle         :integer
#  minutes_between_cycles :integer
#  active                 :boolean          default("true")
#  last_check             :datetime
#  last_error             :string(500)
#  application_id         :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class WorkManager < ApplicationRecord
  extend Enumerize

  belongs_to :application
  has_many :cycles, dependent: :destroy

  include CheckService

  scope :active, -> { where(active: true) }

  validates :name, :aws_region, :autoscalinggroup_name, :queue_name, :max_workers, :min_workers, :jobs_per_cycle, :application, presence: true

  enumerize :active, in: [true, false]

  before_save :default_values
  def default_values
    # self.last_check ||= Time.now
    self.history ||= [{name: "Workers", data: []},{name: "Jobs", data: []}]
  end

  after_save :verify_changes

  def verify_changes
    self.cycles.destroy_all if self.queue_name_previously_changed?
  end

  def to_s
    name
  end

  def total_intervals_period?
    (self.minutes_to_process.to_f / self.cycle_interval.to_f).ceil
  end

  def viable?
    aws_region.present? && autoscalinggroup_name.present? && application.jobs_url.present?
  end

  def jobs_count
    jobs = JobsService.new(self.application.jobs_url).queue_jobs(self.queue_name)
    jobs[:total_jobs]
  rescue => e
    puts e.message
    0
  end

  def workers_count
    AwsService.new(self.cycles.last).total_instances
  end

  def desired_cycles
    [(self.minutes_to_process / self.minutes_between_cycles).to_i,1].max
  rescue
    1
  end

  def workers
    last_cycle = self.cycles.last
    if last_cycle
      last_cycle.workers
    else
      0
    end
  end

  def current_workers
    AwsService.new(self).total_instances
  rescue => e
    puts e.message
    0
  end

  def current_jobs
    jobs_count
  rescue => e
    puts e.message
    0
  end

  def update_history
    history = self.history
    unless history.is_a?(Array) and history[0].present?
      history = [
           {'name' =>  'Workers', 'data' => []},
           {'name' => 'Jobs', 'data' => []}
      ]
    end
    workers = history[0]['data']
    jobs = history[1]['data']
    i = Time.now.strftime('%H:%M:%S')
    workers << [i,self.current_workers]
    jobs << [i,self.current_jobs]
    workers.shift if workers.size > 120
    jobs.shift if jobs.size > 120
    self.update_attribute(:history, history)
    history
  end

end
