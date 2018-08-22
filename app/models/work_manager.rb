class WorkManager < ApplicationRecord
  extend Enumerize

  belongs_to :application
  has_many :cycles, dependent: :destroy

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
    (self.minutes_to_process.to_f / CheckService.cycle_interval.to_f).ceil
  end

  def viable?
    aws_region.present? && autoscalinggroup_name.present? && application.jobs_url.present?
  end

  def jobs_count
    jobs = JobsService.new(self.application.jobs_url).queue_jobs(self.queue_name)
    jobs[:total_jobs]
  rescue => e
    0
  end

  def workers_count
    AwsService.new(self.cycles.last).total_instances
  end

end
