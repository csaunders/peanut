source 'https://rubygems.org'

ruby '2.1.5'

gem 'rack', '1.5.2'
gem 'sinatra'
gem 'sinatra-contrib'
gem 'sinatra-flash'
gem 'redis'
gem 'connection_pool'
gem 'rack-cors'
gem 'omniauth'
gem 'omniauth-google-oauth2'

gem 'capistrano'
gem 'capistrano-passenger'

group :development, :test do
  gem 'dotenv'
  gem 'rspec'
  gem 'cucumber'
  gem 'rack-test'
end

group :development do
  gem 'pry'
  gem 'pry-byebug'
end

group :production do
  gem 'dotenv-deployment'
end
