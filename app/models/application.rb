class Application < ApplicationRecord

  has_many :work_managers, dependent: :destroy
  has_many :cycles, through: :work_managers

  validates :name, :aws_access_key_id, :aws_secret_access_key, :jobs_url, presence: true
  before_save :validate_aws_credentials, :validate_jobs_url

  def validate_aws_credentials
    begin
      AwsService.validate_credentials aws_access_key_id, aws_secret_access_key
      self[:valid_aws_credentials] = true
    rescue Aws::Errors::ServiceError,
        Aws::AutoScaling::Errors::ServiceError => e
      class_path = e.class.to_s.split('::').join('.').underscore
      locale_message_path = I18n.t(class_path, default: nil)
      errors.add(:aws_access_key_id, locale_message_path || e.message)
      errors.add(:aws_secret_access_key, locale_message_path || e.message)
      self[:valid_aws_credentials] = false
    end
  end

  def validate_jobs_url
    begin
      JobsService.new(jobs_url).validate
      self[:valid_jobs_url] = true
    rescue JobsService::InvalidJobUrlGateway => e
      errors.add(:jobs_url, I18n.t(:invalid_jobs_url))
      self[:valid_jobs_url] = false
    rescue  => e
      errors.add(:jobs_url, e.message)
      self[:valid_jobs_url] = false
    end
  end

  def to_s
    name
  end

  def self.status
    apps = []
    self.order(:name).each do |app|
      app.work_managers.each do |work_mgr|
        apps << {
            name: app.name,
            queue: work_mgr.name,
            jobs: work_mgr.jobs_count,
            workers: work_mgr.workers_count
        }
      end
    end
    apps
  end

end
