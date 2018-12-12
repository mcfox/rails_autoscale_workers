require 'rails_helper'

RSpec.describe CheckService, type: :service do

  it 'check_all deve calcular o desired de todos os workers cadastrados' do
    app = Application.create(name: 'app', aws_access_key_id: 'x', aws_secret_access_key: 'y',
                             valid_aws_credentials: true,
                             jobs_url: 'xxxx',
                             valid_jobs_url: true,
                             active: true,
                             )
    wm1 = WorkManager.create(name: 'WM1',
                             aws_region: 'SA-EAST-1',
                             autoscalinggroup_name: 'as_queue1',
                             queue_name: 'queue_1',
                             max_workers: 10,
                             min_workers: 1,
                             minutes_to_process: 30,
                             jobs_per_cycle: 10,
                             minutes_between_cycles: 10,
                             application_id: app.id
                             )
    # simulo a api retornando o numero de jobs na fila
    allow_any_instance_of(JobsService).to receive(:queue_jobs).and_return({ total_jobs: 10 })
    CheckService.check_all
    expect(wm1.cycles.count).to eq(1)
    expect(wm1.cycles.last.desired_workers).to eq(5)

  end



end