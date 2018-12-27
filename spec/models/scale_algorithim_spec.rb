require 'rails_helper'

RSpec.describe ScaleAlgorithim, type: :model do

  before(:each) do
    @worker_capacity = 150
    @scaler = ScaleAlgorithim.new('Teste', 1, @worker_capacity, [], 0, 20)
  end

  it 'deve processar todos os jopbs no SLA definido se não tivermos limite de maquinas' do
    cargas = [500]
    ciclos = ciclos_para_processar_toda_carga(cargas)
    expect(ciclos).to be <= (cargas.size +  3)
  end

  it 'deve comsumir uma fila no prazo definido se não tivermos limite de maquinas' do
    cargas = [300,200,350,100,50,310,120,330,50,10]
    ciclos = ciclos_para_processar_toda_carga(cargas)
    expect(ciclos).to be <= (cargas.size +  3)
  end

  it 'deve comsumir uma fila no prazo definido se não tivermos limite de maquinad' do
    cargas = [0,0,5000,0,0,0,0,5000]
    ciclos = ciclos_para_processar_toda_carga(cargas)
    expect(ciclos).to be <= (cargas.size +  3)
  end


  it 'deve comsumir uma fila no prazo definido se não tivermos limite de maquinad' do
    cargas = [0,1000,1000,1000,1000,1000,5000]
    ciclos = ciclos_para_processar_toda_carga(cargas)
    expect(ciclos).to be <= (cargas.size +  3)
  end

  it 'deve processar uma fila' do
    prng = Random.new
    cargas = []
    20.times do
      cargas << prng.rand(1000)
    end
    ciclos = ciclos_para_processar_toda_carga(cargas)
    expect(ciclos).to be <= (cargas.size +  3)
  end

  # dado uma carga, ele retorna um array com o numereo de maquindas até zerar o numero de maquinas
  # Queremos prever o numero de ciclos em que zeramos a demanda
  def ciclos_para_processar_toda_carga(cargas)
    jobs_in_queue = 0
    processed = 0
    current_workers = 0

    ciclos_count = 0


    # sempre jogo as cargas na fila
    cargas.each do |carga|
      jobs_in_queue += carga
      current_workers = @scaler.desired_workers(jobs_in_queue, carga, processed, current_workers)[0]
      # velocidade de processamento +-20% (de 40 a 60 jobs/min/worker)
      speed = @worker_capacity # 40.0 + 20.0 * (prng.rand(100) / 100.0)
      processed = [speed * current_workers, jobs_in_queue].min
      # sleep 1
      if current_workers == 0 && jobs_in_queue == 0
        puts 'ZZzzz...'
      else
        puts "Total (Novos): #{jobs_in_queue}(#{carga}) => Workers #{current_workers} Cap: #{current_workers*@worker_capacity}"
      end
      jobs_in_queue -= processed
      ciclos_count += 1
    end

    # cooldown carga = 0 até processar tudo
    while true do
      break if jobs_in_queue <= 0 or ciclos_count > 100
      carga = 0
      current_workers = @scaler.desired_workers(jobs_in_queue, carga, processed, current_workers)[0]
      speed = @worker_capacity
      processed = [speed * current_workers, jobs_in_queue].min
      if current_workers == 0 && jobs_in_queue == 0
        puts 'ZZzzz...'
      else
        puts "Ainda falta: #{jobs_in_queue} => Workers #{current_workers}"
      end
      jobs_in_queue -= processed
      ciclos_count += 1
    end

    ciclos_count
  end


end
