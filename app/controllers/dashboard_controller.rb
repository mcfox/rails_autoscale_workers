class DashboardController < ApplicationController

  def index
    @applications = Application.order(:name).all
  end

end
