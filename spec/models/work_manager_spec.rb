require 'rails_helper'

RSpec.describe WorkManager, type: :model do

  before(:each) do
    @jobs_per_cycle = 10
    app = Application.create(name: 'app',
                             aws_access_key_id: 'x',
                             aws_secret_access_key: 'y',
                             valid_aws_credentials: true,
                             jobs_url: 'xxxx',
                             valid_jobs_url: true,
                             active: true,
                             )
    @wm1 = WorkManager.create(name: 'WM1',
                             aws_region: 'SA-EAST-1',
                             autoscalinggroup_name: 'as_queue1',
                             queue_name: 'queue_1',
                             max_workers: 10,
                             min_workers: 0,
                             minutes_to_process: 30,
                             jobs_per_cycle: 10,
                             minutes_between_cycles: 10,
                             application_id: app.id
    )

    allow_any_instance_of(AwsService).to receive(:change_instance_to).and_return(true)
    allow_any_instance_of(AwsService).to receive(:autoscalinggroup_by_name).and_return(Cycle.new)
  end

  it 'simulando sequencia de 30, 150 e 300, e 3000' do
    # simulo a api retornando o numero de jobs na fila
    # com 10 jobs per worker
    # 3 ciclos para processar
    # se caiar 30 jobs
    # tenho que ter apenas 1 worker
    allow_any_instance_of(JobsService).to receive(:queue_jobs).and_return({ new_jobs: 30, total_jobs: 30, processed_jobs: 0 })
    @wm1.check
    expect(@wm1.cycles.last.desired_workers).to eq(1)

    # se cair 150 jobs
    # tenho que ter 5 workers
    allow_any_instance_of(JobsService).to receive(:queue_jobs).and_return({ new_jobs: 150, total_jobs: 150 })
    @wm1.check
    expect(@wm1.cycles.last.desired_workers).to eq(1+5)

    # se cair 300 jobs
    # tenho que ter 10 workers
    allow_any_instance_of(JobsService).to receive(:queue_jobs).and_return({ new_jobs: 300, total_jobs: 300 })
    @wm1.check
    expect(@wm1.cycles.last.desired_workers).to eq(10)

    # se cair 300 jobs
    # tenho que ter 10 workers
    allow_any_instance_of(JobsService).to receive(:queue_jobs).and_return({ new_jobs: 0, total_jobs: 300 })
    @wm1.check
    expect(@wm1.cycles.last.desired_workers).to eq(10)


    allow_any_instance_of(JobsService).to receive(:queue_jobs).and_return({ new_jobs: 0, total_jobs: 0 })
    @wm1.check
    expect(@wm1.cycles.last.desired_workers).to eq(0)

  end

  it 'testando workers map para o esperado' do
    allow_any_instance_of(JobsService).to receive(:queue_jobs).and_return({ new_jobs: 600, total_jobs: 600 })
    @wm1.check
    expect(@wm1.workers_map).to eq('10|10|10|10|10|10')

  end

  it 'deve processar o deficit de um ciclo nos próximos' do

    allow_any_instance_of(JobsService).to receive(:queue_jobs).and_return({ new_jobs: 0, total_jobs: 0 })
    @wm1.check
    expect(@wm1.workers_map).to eq('0|0|0')

    allow_any_instance_of(JobsService).to receive(:queue_jobs).and_return({ new_jobs: 150, total_jobs: 150 })
    @wm1.check
    expect(@wm1.workers_map).to eq('5|5|5')

    # processou somente 90, e caiu mais 30, deficet de 60
    allow_any_instance_of(JobsService).to receive(:queue_jobs).and_return({ new_jobs: 30, total_jobs: 150-30+30 })
    @wm1.check
    # 5|5 ciclo anterior
    # 2|2|2 novo ciclo (30) + deficit de processamento (20)
    # 7|7|2 final
    expect(@wm1.workers_map).to eq('7|7|2')

    allow_any_instance_of(JobsService).to receive(:queue_jobs).and_return({ new_jobs: 0, total_jobs: 80 })
    @wm1.check
    expect(@wm1.workers_map).to eq('7|2|0')

    allow_any_instance_of(JobsService).to receive(:queue_jobs).and_return({ new_jobs: 0, total_jobs: 10 })
    @wm1.check
    expect(@wm1.workers_map).to eq('2|0|0')

    allow_any_instance_of(JobsService).to receive(:queue_jobs).and_return({ new_jobs: 0, total_jobs: 0 })
    @wm1.check
    expect(@wm1.workers_map).to eq('0|0|0')

  end



end