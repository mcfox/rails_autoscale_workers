class IntervalService

  attr_reader :cycle, :work_manager

  def initialize(cycle)
    @cycle = cycle.is_a?(Cycle) ? cycle : Cycle.find(cycle)
    @work_manager = cycle.work_manager
  end

  def calculate
    intervals = build_array_from_array(last_cycle_intervals)

    total_intervals = intervals.size
    processed_jobs = cycle.processed_jobs

    intervals.each_with_index do |interval, i|
      pos = i+1
      processed_jobs_interval = (work_manager.jobs_per_cycle / total_intervals * pos).to_i

      jobs_next_interval = intervals[pos].nil? ? 0 : intervals[pos][1]
      jobs_this_interval = intervals[i][1]

      num_jobs = if pos == total_intervals && cycle.new_jobs > 0
                   cycle.new_jobs
                 elsif jobs_this_interval <= processed_jobs || (pos == 1 && jobs_this_interval > 0)
                   jobs_next_interval + jobs_this_interval
                 else
                   jobs_next_interval
                 end

      if num_jobs >= processed_jobs
        num_jobs = num_jobs - processed_jobs
        processed_jobs = 0
      else
        processed_jobs = processed_jobs - num_jobs
        num_jobs = 0
      end

      desired_workers_interval = (num_jobs.to_f / processed_jobs_interval.to_f).ceil

      interval[0] = pos
      interval[1] = num_jobs
      interval[2] = processed_jobs_interval
      interval[3] = desired_workers_interval
    end

    save_intervals!(intervals)

    intervals
  end

  def last_cycle_intervals
    build_array_from_intervals(cycle.previous.intervals) if cycle.previous.present?
  end

  private
  def save_intervals!(intervals)
    intervals.each do |interval|
      cycle.intervals.create!({
                                   position: interval[0],
                                   jobs: interval[1],
                                   slice_jobs: interval[2],
                                   workers: interval[3]
                               })
    end
  end

  def build_blank_array(rows)
    Array.new(rows) { Array.new(4) { 0 } }
  end

  def build_array_from_intervals(intervals)
    intervals.map { |i| [i[:position], i[:jobs], i[:slice_jobs], i[:workers]] }
  end

  def build_array_from_array(source)
    new_array = build_blank_array(work_manager.total_intervals_period?)
    if source
      if source.size==new_array.size
        new_array = source
      else
        source.each do |i|
          item = new_array.min_by { |t| (t[1].to_f - i[1]).abs }
          new_array[new_array.index(item)][0] = i[0]
        end
      end
    end
    new_array
  end

end