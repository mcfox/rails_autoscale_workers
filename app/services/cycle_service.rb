class CycleService

  attr_reader :job_service, :work_manager

  def initialize(work_manager)
    @work_manager = work_manager.is_a?(WorkManager) ? work_manager : WorkManager.find(work_manager)
    @job_service = JobsService.new(@work_manager.application.jobs_url)
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

      desired_workers = cycle.intervals.sum(:workers)
      desired_workers = 1 if desired_workers.zero? && !cycle.queue_jobs.zero?

      cycle.attributes = {desired_workers: desired_workers, workers: desired_workers}
    end

    cycle.save!
    cycle
  end

  def zero_jobs

  end

end