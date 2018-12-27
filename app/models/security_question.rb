# == Schema Information
#
# Table name: security_questions
#
#  id     :integer          not null, primary key
#  locale :string           not null
#  name   :string           not null
#

class SecurityQuestion < ActiveRecord::Base

  validates :locale, presence: true
  validates :name, presence: true, uniqueness: true
end