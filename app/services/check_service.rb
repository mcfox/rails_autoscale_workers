class CheckService

  attr_reader :work_manager, :cycle_service

  def initialize(work_manager)
    @work_manager = work_manager.is_a?(WorkManager) ? work_manager : WorkManager.find(work_manager)
    @cycle_service = CycleService.new(@work_manager)
  end

  def check
    if work_manager.active? && work_manager.viable?
      cycle = cycle_service.run
      if cycle.is_a?(Cycle)
        AwsService.new(cycle).change_instance_to(cycle.desired_workers)
      else
        raise cycle.to_s
      end

      # elapsed_seconds = (((cycle.updated_at - cycle.previous.updated_at) * 24 * 60 * 60).to_i rescue 0)
      # jobs_per_second = (cycle.processed_jobs / elapsed_seconds rescue 0)

      work_manager.cycles.order(created_at: :desc).offset(100).destroy_all if work_manager.cycles.count > 100 #ONLY LAST 100 CYCLES
      work_manager.update(last_check: CheckService.current_datetime, last_error: nil)
    end

    true
  rescue => e
    work_manager.update(last_error: e.message)
    raise
  end

  def self.check_all
    processed_work_managers = []
    WorkManager.active.where('work_managers.last_check <= ?', CheckService.current_datetime - 4.minutes).order(:last_check).each do |work_manager|
      result = CheckService.new(work_manager).check
      if result.is_a?(Cycle)
        processed_work_managers << work_manager
      end
    end
    # JobMailer.check_all_report(processed_work_managers).deliver if processed_work_managers.count > 0
    processed_work_managers
  end

  def self.current_datetime
    Time.now
  end

  def self.cycle_interval
    5
  end

end