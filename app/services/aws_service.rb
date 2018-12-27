class AwsService

  attr_reader :cycle, :work_manager, :aws
  attr_accessor :autoscalinggroup

  def initialize(cycle)
    @cycle = cycle.is_a?(Cycle) ? cycle : Cycle.find_by(id: cycle)
    if @cycle
      @work_manager = @cycle.work_manager
      @aws = Aws::AutoScaling::Resource.new(region: @work_manager.aws_region, credentials: Aws::Credentials.new(@work_manager.application.aws_access_key_id, @work_manager.application.aws_secret_access_key))
      @autoscalinggroup = autoscalinggroup_by_name(@work_manager.autoscalinggroup_name)
    end
  end

  def autoscalinggroups(options=nil)
    @aws.groups(options)
  end

  def autoscalinggroup_by_name(name)
    autoscalinggroups({auto_scaling_group_names: [name]}).first
  end

  def change_instance_to(desired_workers)
    workers = calculate_viable_number_of_workers(desired_workers)
    cycle.update(workers: workers, current_workers: total_instances)
    autoscalinggroup.update({min_size: workers, max_size: workers, desired_capacity: workers})
  end

  def change_instance_by(number)
    total = (total_instances + number)
    total.negative? ? 0 : total
    change_instance_to total
  end

  def self.autoscalinggroups(application, region)
    application = application.is_a?(Application) ? application : Application.find(application)
    aws = Aws::AutoScaling::Resource.new(region: region, credentials: Aws::Credentials.new(application.aws_access_key_id, application.aws_secret_access_key))
    aws.groups
  end

  def self.regions(application, region='sa-east-1')
    application = application.is_a?(Application) ? application : Application.find(application)
    ec2_client = Aws::EC2::Client.new(region: region, credentials: Aws::Credentials.new(application.aws_access_key_id, application.aws_secret_access_key))
    ec2_client.describe_regions.regions.map.pluck(:region_name)
  end

  def total_instances
    autoscalinggroup.instances.count rescue 0
  end

  def self.validate_credentials(aws_access_key_id, aws_secret_access_key)
    as_client = Aws::AutoScaling::Client.new(region: 'sa-east-1', credentials: Aws::Credentials.new(aws_access_key_id, aws_secret_access_key))
    as_client.describe_lifecycle_hook_types({})
  end

  private

  def calculate_viable_number_of_workers(desired_workers)
    workers = calculate_allowed_workers(desired_workers)
    limit_to_min_max_workers(workers)
  end

  def limit_to_min_max_workers(workers)

    # Limte máximo e mínimo, conforme definido no worker
    min = work_manager.min_workers || 0
    max = work_manager.max_workers || 10

    time_now = Time.now.in_time_zone('America/Sao_Paulo')
    hour = time_now.hour
    weekday = time_now.wday
    off_time = weekday.in?([0,7]) && (hour > 22 || hour < 6)

    if off_time
      min = work_manager.min_workers_off || min
      max = work_manager.max_workers_off || max
    end

    if workers > max
      max
    elsif workers < min
      min
    else
      workers
    end
  end

  def calculate_allowed_workers(workers_number)
    total_current_workers = total_instances
    if total_current_workers >= workers_number
      instances = describe_instances
      launched_times = instances.is_a?(Array) && instances.size > 0 ? instances.map{|i| i.launch_time }.flatten : []
      workers_possible_to_kill = measure_usage_time(launched_times)
      workers_desired_to_kill = total_current_workers - workers_number
      workers_number = total_current_workers - (workers_possible_to_kill > workers_desired_to_kill ? workers_desired_to_kill : workers_possible_to_kill)
    end
    workers_number
  end

  def describe_instances
    ec2 = Aws::EC2::Client.new(region: work_manager.aws_region, credentials: Aws::Credentials.new(work_manager.application.aws_access_key_id, work_manager.application.aws_secret_access_key))
    instances_id =  autoscalinggroup.instances.map(&:id)
    return [] if instances_id.empty?
    resp = ec2.describe_instances(instance_ids: instances_id)
    resp.reservations.map{|r| r.instances}.flatten
  end

  def measure_usage_time(times)
    times.inject(0) {|i, time| exceeded_minimun_usage_time?(time) ? i+1 : i }
  end

  def exceeded_minimun_usage_time?(launch_time)
    # tempo_minimo = 15
    Time.now > launch_time + 15.minutes
  end
  


end