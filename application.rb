require 'sinatra/base'
require 'rack/cors'
require 'dotenv'

require 'user'
require 'typo'

Dotenv.load

use Rack::Cors do
  allow do
    origins '*'
    resource '/typo/*', headers: :any, methods: :post
  end
end

class PeanutApp < Sinatra::Base
  enable :sessions
  set :session_secret, ENV['SESSION_SECRET']

  set :public_folder, File.dirname(__FILE__) + '/public'
  set :views, settings.root + '/views'

  # Brochure
  get '/' { erb :index }

  # Authentication
  get '/login' { erb :login }

  post '/login' do
  end

  post '/logout' do
  end

  # Logged In
  get '/typos' do
  end

  # Typo Submission
  post '/typo/:uuid' do
  end
end

