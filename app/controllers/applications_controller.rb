class ApplicationsController < ApplicationController

  before_action :set_application, only: [:show, :edit, :update, :destroy]

  def index
    @applications = Application.order(:name)
  end

  def show
  end

  def new
    @application = Application.new
  end

  def edit
  end

  def create
    @application = Application.new(application_params)
    @application.save
    respond_with @application
  end

  def update
    @application.update(application_params)
    respond_with @application
  end

  def destroy
    @application.destroy
    respond_with @application
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_application
    @application = Application.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def application_params
    params.require(:application).permit(:id, :name, :aws_access_key_id, :aws_secret_access_key, :jobs_url)
  end

end
