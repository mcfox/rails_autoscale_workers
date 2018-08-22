set :stage, :production
set :puma_env, fetch(:rack_env, fetch(:rails_env, 'production'))

role :app, %w{deploy@ec2-54-89-139-204.compute-1.amazonaws.com}
role :web, %w{deploy@ec2-54-89-139-204.compute-1.amazonaws.com}
role :db,  %w{deploy@ec2-54-89-139-204.compute-1.amazonaws.com}

#fetch(:default_env).merge!(rails_env: :production)