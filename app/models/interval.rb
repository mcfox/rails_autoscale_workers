# == Schema Information
#
# Table name: intervals
#
#  id         :integer          not null, primary key
#  cycle_id   :integer
#  position   :integer          default(0)
#  jobs       :integer          default(0)
#  slice_jobs :integer          default(0)
#  workers    :integer          default(0)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Interval < ApplicationRecord

  validates :cycle, presence: true

  belongs_to :cycle
end
