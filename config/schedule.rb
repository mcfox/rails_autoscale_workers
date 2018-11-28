set :output, "log/cron_log.log"
env :PATH, ENV['PATH']
# a cada 5 minutos, rodo o calculo de workers
every 5.minutes do
  rake "check_service:check_all"
end
