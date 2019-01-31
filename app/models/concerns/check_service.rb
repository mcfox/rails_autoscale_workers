module CheckService
  extend ActiveSupport::Concern

  # crio um ciclo com o numero de maquinas desejadas
  # para a demanda atual
  def create_cycle(total_jobs, new_jobs, processed_jobs)
    last_cycle = self.cycles.last
    current_workers = last_cycle ? last_cycle.workers : 0
    cycle = self.cycles.create
    cycle.processed_jobs = processed_jobs
    cycle.queue_jobs = total_jobs
    cycle.new_jobs = new_jobs
    # calculo e atualizo esse ciclo com o numero de workers necessários
    cycle.calc_desired_workers(current_workers)
    cycle
  end

  # crio o próximo ciclo
  def create_new_cycle
    wm = self
    last_cycle = wm.cycles.last
    if last_cycle
      last_datetime = last_cycle.updated_at
      last_queue_jobs = last_cycle.queue_jobs
    else
      last_datetime = nil
      last_queue_jobs = nil
    end

    js = JobsService.new(self.application.jobs_url)
    jobs = js.queue_jobs(self.queue_name, last_datetime)
    if jobs.is_a?(String) # ERROR
      return jobs
    end
    processed_jobs = js.calculate_processed_jobs(last_queue_jobs, jobs[:total_jobs],jobs[:new_jobs])
    create_cycle(jobs[:total_jobs], jobs[:new_jobs], processed_jobs)
  end

  # verifico na fila quantos jobs tem
  # e calculo quantas maquinda quero manter para esse ciclo e os demais
  def check
    if self.active? && self.viable?
      cycle = create_new_cycle
      if cycle.is_a?(Cycle)
        aws_connection = AwsService.new(self)
        if aws_connection
          aws_connection.change_instance_to(cycle.desired_workers)
        else
          raise 'Não foi possivel conectar ao serviço de autoscaling da AWS'
        end
      else
        raise cycle.to_s
      end

      # keeo only 100 cycles
      if self.cycles.count > 100
        self.cycles.order(created_at: :desc).offset(100).destroy_all
      end

      self.update(last_check: Time.now, last_error: nil)
    end

    true
  rescue => e
    self.update(last_error: e.message)
    raise
  end

  def cycle_interval
    5
  end

  module ClassMethods

    def check_all
      processed_work_managers = []
      WorkManager.active.order(:last_check).each do |work_manager|
        result = CheckService.new(work_manager).check
        if result.is_a?(Cycle)
          processed_work_managers << work_manager
        end
      end
      # JobMailer.check_all_report(processed_work_managers).deliver if processed_work_managers.count > 0
      processed_work_managers
    end

  end

end