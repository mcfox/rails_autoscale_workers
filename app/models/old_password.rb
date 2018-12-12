# == Schema Information
#
# Table name: old_passwords
#
#  id                       :integer          not null, primary key
#  created_at               :datetime
#  updated_at               :datetime         not null
#  encrypted_password       :string           not null
#  password_archivable_type :string           not null
#  password_archivable_id   :integer          not null
#  password_salt            :string
#

class OldPassword < ActiveRecord::Base

    belongs_to :password_archivable, polymorphic: true
end
