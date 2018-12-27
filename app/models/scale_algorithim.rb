class ScaleAlgorithim


  def initialize(queue_name, target_cycles, worker_capacity_per_cycle, worksets=nil, min_workers=1, max_workers=20)
    # caso precise persistir em banco
    @queue_name = queue_name
    @target_cycles = target_cycles
    @min_workers = min_workers
    @max_workers = max_workers
    @worker_capacity_per_cycle = worker_capacity_per_cycle

    # variaveis auxiliares
    @worksets = worksets || []
  end

  # calulo o numero de workers desejados, levando em conta
  # um eventual deficit de processamento
  # total = Numero de jobs atualmente na fila
  # new = Qtd de jobs adicionados no último ciclo
  # processed = Qtd de jobs processados no último ciclo
  # current_workers = numero atual de workers
  #
  def desired_workers(total, new, processed, current_workers)

    # elimino o ciclo passado de todos os worksets já existentes
    @worksets.each do |workset|
      @worksets.delete(workset) if workset.empty?
    end
    @worksets.each do |workset|
      workset.shift
    end

    # Novo workset para os novos jobs, levando em conta eventuais deficits
    # devido diferença entre o esperado e o realmente processasdo
    expected = current_workers * @worker_capacity_per_cycle
    jobs_adjustment = (expected - processed)

    if jobs_adjustment < 0
      jobs_adjustment = 0
    end

    if jobs_adjustment > total
      jobs_adjustment = total
    end

    new_load = (new || 0) + (jobs_adjustment || 0)
    if new_load > 0
      @worksets << new_work_set(new_load, @worker_capacity_per_cycle)
    else
      @worksets << new_work_set(0, @worker_capacity_per_cycle)
    end
    # calculo o final levando em conta todos os worksets
    workers = calc_final_desired_workers(total)
    [workers, @worksets]
  end

  # levo em conta todas as worksets calculados
  # e somo os workers do primeiro ciclo
  def calc_final_desired_workers(total=0)
    required_workers = 0
    @worksets.each do |workset|
      required_workers += workset[0] if workset && workset[0]
    end

    # casos extremoa para garantir
    # mas se tiver um job, tenho um worker
    if required_workers == 0 && total > 0
      required_workers = 1
    end
    # se não tenho nada, não tenho worker
    if total.zero?
      required_workers = 0
    end

    required_workers = [required_workers, @max_workers].min
    required_workers = [required_workers, @min_workers].max
    required_workers
  end


  # calculo quantos workers são necessarios para matar esses jobs durante Target ciclos
  def new_work_set(new, worker_speed)
    return nil unless worker_speed > 0
    workers = ((new.to_f / @target_cycles.to_f) / @worker_capacity_per_cycle.to_f).ceil
    workset = []
    estimated_to_process = 0
    max_cycle_capactity = @max_workers * @worker_capacity_per_cycle
    max_target_capactity = max_cycle_capactity * @target_cycles

    # se estiver numa situacao limite
    if new > max_target_capactity
      cycles_at_maximum_speed = new / max_cycle_capactity
      cycles_at_maximum_speed.times do
        workset << @max_workers
      end
    else
      @target_cycles.times do
        workset << workers
        estimated_to_process += workers * @worker_capacity_per_cycle
        break if estimated_to_process > new
      end
    end
    workset
  end

end