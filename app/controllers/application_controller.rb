require "application_responder"

class ApplicationController < ActionController::Base

  before_action :authenticate_user!
  before_action :set_responders, unless: :devise_controller?

  private
  def set_responders
    self.class.responder = ApplicationResponder
    self.class.respond_to :html, :json, :js
  end

end
