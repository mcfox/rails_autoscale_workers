class ScaleAlgorithim


  def initialize(queue_name, worker_capacity_per_cycle,  min_workers=1, max_workers=20)
    # caso precise persistir em banco
    @queue_name = queue_name
    @min_workers = min_workers
    @max_workers = max_workers
    @worker_capacity_per_cycle = worker_capacity_per_cycle
  end

  def desired_workers(total, new, processed, current_workers)
    required_workers = (total.to_f/ @worker_capacity_per_cycle.to_f).ceil
    # casos extremoa para garantir
    # mas se tiver um job, tenho um worker
    if total > 0 && required_workers == 0
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


end