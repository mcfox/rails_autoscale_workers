LoginMcfox.configuration do |config|

  #Application name
  config.app_name = "ASWorkers"

  #Logotipo in app/assets/images
  config.logo_file_name = "asw.png"

  #Show google login button?
  config.enable_google = false

  #Show LinkedIn web login button?
  config.enable_linkedin = false

  #Show create account link?
  config.enable_create_account = false

  #Custom Controllers
  # config.devise_controllers = {
  #     omniauth_callbacks: 'omniauth_callbacks',
  #     registrations: 'registrations',
  #     confirmations: 'confirmations',
  #     invitations: 'invitations',
  #     sessions: 'sessions',
  #     passwords: 'passwords',
  #     unlocks: 'unlocks'
  # }

end