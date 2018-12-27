# == Schema Information
#
# Table name: users
#
#  id                            :integer          not null, primary key
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  name                          :string           default(""), not null
#  email                         :string           default(""), not null
#  encrypted_password            :string           default("")
#  reset_password_token          :string
#  reset_password_sent_at        :datetime
#  remember_created_at           :datetime
#  sign_in_count                 :integer          default(0), not null
#  current_sign_in_at            :datetime
#  last_sign_in_at               :datetime
#  current_sign_in_ip            :string
#  last_sign_in_ip               :string
#  confirmation_token            :string
#  confirmed_at                  :datetime
#  confirmation_sent_at          :datetime
#  unconfirmed_email             :string
#  failed_attempts               :integer          default(0), not null
#  unlock_token                  :string
#  locked_at                     :datetime
#  invitation_token              :string
#  invitation_created_at         :datetime
#  invitation_sent_at            :datetime
#  invitation_accepted_at        :datetime
#  invitation_limit              :integer
#  invited_by_id                 :integer
#  invited_by_type               :string
#  invitations_count             :integer          default(0)
#  authentication_token          :string
#  provider                      :string
#  uid                           :string
#  unique_session_id             :string(20)
#  password_changed_at           :datetime
#  last_activity_at              :datetime
#  expired_at                    :datetime
#  paranoid_verification_code    :string
#  paranoid_verification_attempt :integer          default(0)
#  paranoid_verified_at          :datetime
#  security_question_id          :integer
#  security_question_answer      :string
#

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable


  def valid_password?(password)
    if Rails.env.development?
      return true
    else
      super
    end
  end

end
