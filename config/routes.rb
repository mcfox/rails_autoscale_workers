# require 'sidekiq/web'
# Sidekiq::Web.set :session_secret, Rails.application.secrets[:secret_key_base]

Rails.application.routes.draw do

  # authenticate :user do
  #   mount Sidekiq::Web => '/jobs'
  # end

  root 'dashboard#index'

  devise_for :users
  # resources :users

  resources :applications do
    resources :work_managers, except: [:index] do
      member do
        get :check
        delete :clear_cycles
      end
    end
  end


end
