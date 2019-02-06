class WorkManagersController < ApplicationController

  before_action :set_application
  before_action :set_work_manager, only: [:show, :edit, :update, :destroy, :active, :check, :clear_cycles, :chart_data]

  def show
    @data = [{name: 'workers', data: []}, {name: 'jobs', data: []}]
    @chart_options = {
        width: 400,
        height: 240,
        title: 'Jobs x Workers',
        vAxis: [0 => {format: '#'}, 1 => {format: '#'}],
        hAxis: { title: "Hora", format: 'H:M:S'},
        series: {
          0 => { type: "line", targetAxisIndex: 0 },
          1 =>  { type: "line", targetAxisIndex: 1}
        }
    }
  end

  def new
    @work_manager = @application.work_managers.new
  end

  def edit
  end

  def create
    @work_manager = @application.work_managers.new(work_manager_params)
    @work_manager.save
    respond_with(@application, @work_manager)
  end

  def update
    @work_manager.update(work_manager_params)
    respond_with(@application, @work_manager)
  end

  def destroy
    @work_manager.destroy
    respond_with(@application, @work_manager, location: application_path(@application))
  end

  def check
    begin
      @work_manager.check
      flash[:success] = 'Checagem Efetuada!'
    rescue => e
      flash[:error] = "Ocorreu um erro ao tentar efetuar a checagem: #{e.message} : #{e.backtrace}"[0..1200]
      puts e.backtrace
    end
    redirect_to [@application, @work_manager]
  end

  def clear_cycles
    @work_manager.cycles.destroy_all
    respond_with(@application, @work_manager)
  end

  def chart_data
    respond_with(@work_manager.current_status)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_work_manager
    @work_manager = @application.work_managers.find(params[:id])
  end

  def set_application
    @application = Application.find(params[:application_id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def work_manager_params
    params.require(:work_manager).permit(:id, :name, :aws_region, :autoscalinggroup_name, :queue_name, :max_workers, :min_workers, :max_workers_off, :min_workers_off, :minutes_to_process, :jobs_per_cycle, :active)
  end

  def x
    {
        "type": "line",
        "data": {"labels": [], "datasets": [{"label": "workers", "data": [], "fill": false, "borderColor": "#3366CC", "backgroundColor": "#3366CC", "pointBackgroundColor": "#3366CC", "borderWidth": 2, "pointHoverBackgroundColor": "#3366CC"}, {"label": "jobs", "data": [], "fill": false, "borderColor": "#DC3912", "backgroundColor": "#DC3912", "pointBackgroundColor": "#DC3912", "borderWidth": 2, "pointHoverBackgroundColor": "#DC3912"}]},
        "options": {
            "maintainAspectRatio": false,
            "animation": false,
            "tooltips": {"displayColors": false, "callbacks": {}},
            "legend": {},
            "title": {"fontSize": 20, "fontColor": "#333"},
            "scales": {
                     "yAxes": [
                         {
                             "ticks": {"maxTicksLimit": 4, "min": 0, "max": 1},
                              "scaleLabel": {"fontSize": 16, "fontColor": "#333"}
                         }
                     ],
                     "xAxes": [
                         {
                             "gridLines": {"drawOnChartArea": false},
                             "scaleLabel": {"fontSize": 16, "fontColor": "#333"},
                             "time": {},
                             "ticks": {},
                             "type": "linear",
                             "position": "bottom"
                         }
                     ]
                 },
             "series": {"0": {"targetAxisIndex": 0}, "1": {"targetAxisIndex": 1}},
             "vAxes": {"0": {"title": "Temps (Celsius)"}, "1": {"title": "Daylight"}}
     }
    }


  end
end