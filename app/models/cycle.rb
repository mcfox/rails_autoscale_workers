# == Schema Information
#
# Table name: cycles
#
#  id              :integer          not null, primary key
#  work_manager_id :integer
#  queue_jobs      :integer          default(0)
#  new_jobs        :integer          default(0)
#  processed_jobs  :integer          default(0)
#  workers         :integer          default(0)
#  desired_workers :integer          default(0)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  current_workers :integer          default(0)
#

class Cycle < ApplicationRecord

  validates :work_manager, presence: true

  belongs_to :work_manager
  has_many :intervals, dependent: :destroy

  scope :recent, -> { order(updated_at: :desc) }
  scope :last_cycles, -> { recent.limit(10) }

  def previous
    self.work_manager.cycles.where('created_at < ?', self.created_at).order(:created_at).last
  end

  def calc_desired_workers(current_workers)
    wm = self.work_manager
    scaler = ScaleAlgorithim.new(wm.queue_name,
                                 wm.desired_cycles,
                                 wm.jobs_per_cycle,
                                 wm.workset,
                                 wm.min_workers,
                                 wm.max_workers)
    workers, workeset = scaler.desired_workers(self.queue_jobs, self.new_jobs, self.processed_jobs, current_workers)
    wm.save_workset workeset
    self.desired_workers = workers
    self.workers = workers
    self.save!
    workers
  end

end
