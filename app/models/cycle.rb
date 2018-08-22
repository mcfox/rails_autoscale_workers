class Cycle < ApplicationRecord

  validates :work_manager, presence: true

  belongs_to :work_manager
  has_many :intervals, dependent: :destroy

  scope :recent, -> { order(updated_at: :desc) }
  scope :last_cycles, -> { recent.limit(10) }

  def previous
    self.work_manager.cycles.where('created_at < ?', self.created_at).order(:created_at).last

    # self.work_manager.cycles.where('id < ?', self.id).last

    # last_cycle = self.work_manager.cycles.where('id < ?', self.id).last
    # last_cycle = self.work_manager.cycles.new(created_at: Time.now, updated_at: Time.now) unless last_cycle
    # last_cycle.intervals = Array.new(self.work_manager.total_intervals_period?){Interval.new} unless last_cycle.intervals.count > 0
    # last_cycle
  end

end
