# a cada 5 minutos, rodo as validações
every 5.minutes do
  rake "check_service:check_all"
end
