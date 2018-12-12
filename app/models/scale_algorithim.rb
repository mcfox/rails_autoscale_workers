class ScaleAlgorithim


  def initialize(queue_name, target_minutes, initial_speed, cycle_duration_in_minutes=5, min_workers=0, max_workers=990)
    # caso precise persistir em banco
    @queue_name = queue_name

    # parametros para configurar o escalador
    @target_minutes = target_minutes
    @cycle_duration_in_minutes = cycle_duration_in_minutes
    @min_workers = min_workers
    @max_workers = max_workers

    # variaveis auxiliares
    @cycles_per_target = target_minutes / cycle_duration_in_minutes
    @min_speed = initial_speed
    @last_speed = initial_speed
    @worksets = []
  end

  # calulo o numero de workers desejados, levando em conta
  # um eventual deficit de processamento
  # total = Numero de jobs atualmente na fila
  # new = Qtd de jobs adicionados no último ciclo
  # processed = Qtd de jobs processados no último ciclo
  # current_workers = numero atual de workers
  #
  def desired_workers(total, new, processed, current_workers)

    worker_speed = calc_worker_speed(processed, current_workers)

    # elimino o ciclo passado de todos os worksets já existentes
    @worksets.each do |workset|
      if workset.empty?
        @worksets.delete(workset)
      else
        workset.shift
      end
    end

    # Novo workset para os novos jobs, levando em conta eventuais deficits
    # devido diferença entre o esperado e o realmente processasdo
    expected = current_workers * worker_speed * @cycle_duration_in_minutes
    deficit = [expected - processed,0].max
    @worksets << new_work_set(new + deficit, worker_speed)

    # calculo o final levando em conta todos os worksets
    workers_count = calc_final_desired_workers
    # mas se tiver um job, tenho um worker
    if workers_count == 0 && total > 0
      workers_count = 1
    end
    workers_count
  end

  # levo em conta todas as worksets calculados
  # e somo os workers do primeiro ciclo
  def calc_final_desired_workers
    required_workers = 0
    @worksets.each do |workset|
      required_workers += workset[0] if workset && workset[0]
    end
    required_workers = [required_workers, @max_workers].min
    required_workers = [required_workers, @min_workers].max
    required_workers
  end

  # calulo a velocidade, ajustada se for supoerior a informada, mas a informada é o mínimo
  def calc_worker_speed(processed, current_workers)
    if current_workers > 0 && @cycle_duration_in_minutes > 0 && processed > 0
      @last_speed = ((processed.to_f / current_workers.to_f) / @cycle_duration_in_minutes.to_f).round(0)
    else
      @last_speed
    end
    [@last_speed,@min_speed].max
  end

  # calculo quantos workers são necessarios para matar esses jobs durante Target ciclos
  def new_work_set(new, worker_speed)
    return nil unless worker_speed > 0
    workers = ((new.to_f / @cycles_per_target.to_f) / (worker_speed.to_f * @cycle_duration_in_minutes.to_f)).ceil
    workset = []
    estimated_to_process = 0
    @cycles_per_target.times do
      workset << workers
      estimated_to_process += workers * worker_speed * @cycle_duration_in_minutes
      break if estimated_to_process > new
    end
    workset
  end

  def run_cycle(total, new, processed, current_workers)
    workers = desired_workers(total||0, new ||0, processed||0, current_workers||0)
    max_workers = ( total.to_f / @last_speed * @cycle_duration_in_minutes.to_f).ceil
    [max_workers,workers].min
  end


end