class DashboardController < ApplicationController

  skip_before_action :authenticate_user!, only: [:index]

  def index
    @work_managers = WorkManager.includes(:application).order(:name)
  end

end
