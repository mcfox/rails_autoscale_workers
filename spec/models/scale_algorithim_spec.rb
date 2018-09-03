require 'rails_helper'

RSpec.describe ScaleAlgorithim, type: :model do

  before(:each) do
    @v0 = 50
    @ciclo = 5
    @current_workers = 0
    target  = 15
    @scaler = ScaleAlgorithim.new('Teste', target, @v0, @ciclo)
  end

  it 'deve comsumir uma fila no prazo definido se não tivermos limite de maquinad' do
    cargas = [0,500]
    jobs_in_queue = simulate_queues_random(cargas)
    expect(jobs_in_queue).to eq(0)
  end

  it 'deve comsumir uma fila no prazo definido se não tivermos limite de maquinad' do
    cargas = [300,200,350,100,50,310,120,330,50,10]
    jobs_in_queue = simulate_queues_random(cargas)
    expect(jobs_in_queue).to eq(0)
  end

  it 'deve comsumir uma fila no prazo definido se não tivermos limite de maquinad' do
    cargas = [0,0,5000,0,0,0,0,5000]
    jobs_in_queue = simulate_queues_random(cargas)
    expect(jobs_in_queue).to eq(0)
  end


  it 'deve comsumir uma fila no prazo definido se não tivermos limite de maquinad' do
    cargas = [0,1000,1000,1000,1000,1000,5000]
    jobs_in_queue = simulate_queues_random(cargas)
    expect(jobs_in_queue).to eq(0)
  end

  it 'deve processar uma fila' do
    prng = Random.new
    cargas = []
    20.times do
      cargas << prng.rand(1000)
    end
    jobs_in_queue = simulate_queues_random(cargas)
    expect(jobs_in_queue).to eq(0)
  end

  def simulate_queues_random(cargas)
    jobs_in_queue = 0
    processed = 0
    prng = Random.new
    # sempre jogo 5 ciclos vazios e vejo se zera os workers
    (cargas + [0,0,0,0,0]).each do |carga|
      jobs_in_queue += carga
      current_workers = @scaler.run_cycle(jobs_in_queue, carga, processed, current_workers)
      # velocidade de processamento +-20% (de 40 a 60 jobs/min/worker)
      speed = 40.0 + 20.0 * (prng.rand(100) / 100.0)
      processed = [speed * @ciclo * current_workers, jobs_in_queue].min
      # sleep 1
      if current_workers == 0 && jobs_in_queue == 0
        puts 'ZZzzz...'
      else
        puts "Total (Novos): #{jobs_in_queue}(#{carga}) => Workers #{current_workers}"
      end
      jobs_in_queue -= processed
    end
    jobs_in_queue
  end


end
