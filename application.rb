$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'sinatra/base'
require 'rack/cors'
require 'omniauth'
require 'omniauth-google-oauth2'
require 'dotenv'

require 'lib/storage'
require 'user'
require 'typo'
require 'auth'

Dotenv.load
Storage.factory = Object.const_get(ENV['STORAGE_CONTAINER']).builder

class PeanutApp < Sinatra::Base
  use Rack::Cors do
    allow do
      origins '*'
      resource '/typo/*', headers: :any, methods: :post
    end
  end

  use OmniAuth::Builder do
    provider :google_oauth2, ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET']
  end

  enable :sessions
  set :session_secret, ENV['SESSION_SECRET']

  set :public_folder, File.dirname(__FILE__) + '/public'
  set :views, settings.root + '/views'

  # Brochure
  get '/' do; erb :index; end

  # Authentication
  get '/auth/failure' do; erb :auth_failure; end

  get '/auth/:provider/callback' do
    uid = auth.login(request.env['omniauth.auth'])
    user = User.new(uid)
    user.save

    redirect to('/admin')
  end

  post '/logout' do
    auth.logout
    redirect to('/')
  end

  # Logged In
  before '/admin/*' do
    authenticate!
  end

  get '/admin' do
    """
    <p>Welcome #{session[:uid]}!</p>

    <ul>
      <li><a href=\"/admin/typos\">Check out Reported Typos</a></li>
      <li><a href=\"/admin/sites\">Manage Sites</a></li>
    </ul>
    """
  end

  get '/admin/typos' do
  end

  get '/admin/typos/:fingerprint' do
  end

  get '/admin/sites' do
  end

  post '/admin/sites' do
  end

  delete '/admin/sites/:uuid' do
  end

  # Typo Submission
  post '/typos/:uuid' do
  end

  private
  def auth
    @auth ||= Auth.new(session)
  end

  def user
    @user ||= User.find(session[:uid])
  end

  def logged_in?
    not user.nil?
  end

  def authenticate!
    redirect to('/') unless logged_in?
  end
end

