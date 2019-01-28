require 'rails_helper'

RSpec.describe ScaleAlgorithim, type: :model do

  before(:each) do
    @worker_capacity = 150  # 150 jobs por ciclo
    @scaler = ScaleAlgorithim.new('Teste',  @worker_capacity,  0, 200)
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
    @jobs_in_queue = 0
    @current_workers = 0
    @ciclos_count = 0
    @processed = 0

    # sempre jogo as cargas na fila
    cargas.each do |carga|
      run_cycle(carga)
    end

    # cooldown carga = 0 até processar tudo
    while true do
      break if @jobs_in_queue <= 0 or @ciclos_count > 100
      run_cycle(0)
    end

    # retorno o numero de ciclos até zerar
    @ciclos_count
  end

  def run_cycle(carga)
    @jobs_in_queue += carga
    @current_workers = @scaler.desired_workers(@jobs_in_queue, carga, @processed, @current_workers)
    # print_workers
    @processed = [@worker_capacity * @current_workers, @jobs_in_queue].min
    @jobs_in_queue -= @processed
    @ciclos_count += 1
    @processed
  end

  def print_workers
    if @current_workers == 0 && @jobs_in_queue == 0
      puts 'ZZzzz...'
    else
      puts "Processando [#{@jobs_in_queue}] jobs com [#{@current_workers}] workers"
    end
  end

end
