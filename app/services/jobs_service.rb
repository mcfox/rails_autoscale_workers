class JobsService

  class InvalidJobUrlGateway < StandardError; end

  attr_reader :gateway_url, :jobs

  def initialize(gateway_url)
    @gateway_url = gateway_url
    empty_jobs
  end

  def queue_jobs(queue_name, last_datetime=nil)
    datetime = last_datetime.nil? ? Time.now : last_datetime
    response = RestClient.get"#{gateway_url}/#{queue_name}/#{datetime.iso8601}", {accept: :json}
    @jobs = JSON.parse(response.body).symbolize_keys
    @jobs[:new_jobs] = @jobs[:total_jobs] if last_datetime.nil?
    @jobs
  rescue => e
    e.message
  end

  def calculate_processed_jobs(last_jobs, current_jobs=nil, new_jobs=nil)
    return 0 if last_jobs.nil?
    current_jobs = jobs[:total_jobs] if current_jobs.nil?
    new_jobs = jobs[:new_jobs] if new_jobs.nil?
    ((last_jobs - current_jobs) + new_jobs).abs
  end

  def empty_jobs
    @jobs = {total_jobs: 0, new_jobs: 0}
  end

  def validate
    RestClient.get(gateway_url)
    true
  rescue RestClient::ExceptionWithResponse => e
    raise InvalidJobUrlGateway, e.message #e.response
  end
end