namespace :check_service do

  desc "Check All Jobs WorkManagers"
  task check_all: :environment do
    CheckService.check_all
  end

end
