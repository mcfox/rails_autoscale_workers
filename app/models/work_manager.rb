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

  validates :name, :aws_region, :autoscalinggroup_name, :queue_name, :max_workers, :min_workers, :minutes_to_process, :jobs_per_cycle, :application, presence: true

  enumerize :active, in: [true, false]

  before_save :default_values
  def default_values
    # self.last_check ||= Time.now
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



  def save_workset(workeset)
    self.workset_array = workeset.to_json
    self.save
  end

  def workset
    if self.workset_array.present?
      JSON.parse(self.workset_array)
    else
      []
    end
  end

  def workers_map
    final_workers = []
    workset.each do |set|
      set.each_with_index do |workers_count,i|
        final_workers[i] = (final_workers[i] || 0) + workers_count
      end
    end
    wm = final_workers.join('|')
    puts wm
    wm
  end

end
