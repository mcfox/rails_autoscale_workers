class Interval < ApplicationRecord

  validates :cycle, presence: true

  belongs_to :cycle
end
