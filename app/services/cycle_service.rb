class CycleService

  attr_reader :job_service, :work_manager

  def initialize(work_manager)
    @work_manager = work_manager.is_a?(WorkManager) ? work_manager : WorkManager.find(work_manager)
    @job_service = JobsService.new(@work_manager.application.jobs_url)

    queue_name = @work_manager.queue_name
    target = @work_manager.minutes_to_process
    initial_speed = @work_manager.jobs_per_cycle / @work_manager.minutes_between_cycles
    cycle_duration_in_minutes = @work_manager.minutes_between_cycles
    min_workers = @work_manager.min_workers
    max_workers = @work_manager.max_workers

    @scaler = ScaleAlgorithim.new(queue_name, target, initial_speed, cycle_duration_in_minutes, min_workers, max_workers)
  end

  def run
    cycle = work_manager.cycles.create

    last_cycle = cycle.previous
    if last_cycle.nil?
      last_datetime = nil
      last_queue_jobs = nil
    else
      last_datetime = last_cycle.updated_at
      last_queue_jobs = last_cycle.queue_jobs
    end

    jobs = job_service.queue_jobs(work_manager.queue_name, last_datetime)
    if jobs.is_a?(String) # ERROR
      cycle.destroy
      return jobs
    end

    cycle.processed_jobs = job_service.calculate_processed_jobs(last_queue_jobs)
    cycle.queue_jobs = jobs[:total_jobs]
    cycle.new_jobs = jobs[:new_jobs]

    if cycle.queue_jobs.zero?
      cycle.attributes = {desired_workers: 0, workers: 0}
    else
      interval_service = IntervalService.new(cycle)
      interval_service.calculate
      current_workers = 0
      current_workers = last_cycle.workers if last_cycle
      # código antigo
      # desired_workers = cycle.intervals.sum(:workers)
      # Algoritimo para o calculo de workers necessários
      desired_workers = @scaler.run_cycle(cycle.queue_jobs,
                                          cycle.new_jobs,
                                          cycle.processed_jobs,
                                          current_workers)

      # garanto pelo menos 1 se tiver jobs pendentes
      desired_workers = 1 if desired_workers.zero? && !cycle.queue_jobs.zero?

      cycle.desired_workers = desired_workers
      cycle.workers = desired_workers
    end

    cycle.save!
    cycle
  end


end