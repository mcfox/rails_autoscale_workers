source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.1'

gem 'rails', '~> 5.2.1'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 3.11'
gem 'uglifier', '>= 1.3.0'
gem 'webpacker'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.5'
gem 'bcrypt', '~> 3.1.12'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'easy_captcha', git: 'git@github.com:brunoporto/easy_captcha.git'
gem 'devise-security', git: 'git@github.com:brunoporto/devise-security.git'
gem 'sidekiq', '~> 5.2'
gem 'haml', '~> 5.0'
gem 'simple_form', '~> 4.0'
gem 'simple-navigation', '~> 4.0'
gem 'foreman', '~> 0.6'
gem 'responders', '~> 2.4'
gem 'whenever', '~> 0.10', require: false
gem 'aws-sdk', '~> 2.0'
gem 'aws-sdk-rails', '~> 1.0'
gem 'rest-client', '~> 2.0'
gem 'enumerize', '~> 2.2'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails', '~> 3.8'
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'capistrano', '~> 3.7'
  gem 'capistrano-yarn', '~> 2.0'
  gem 'capistrano-rails', '~> 1.2'
  gem 'capistrano-rvm', '~> 0.1'
  gem 'capistrano-bundler', '~> 1.2'
  gem 'capistrano3-puma', '~> 3.1'
end


# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
# gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
