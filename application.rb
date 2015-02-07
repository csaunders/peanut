$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'sinatra/base'
require 'rack/cors'
require 'omniauth'
require 'omniauth-google-oauth2'
require 'dotenv'

require 'lib/storage'
require 'lib/workers'
require 'user'
require 'typo'
require 'auth'
require 'seeds'

Dotenv.load
Storage.factory = Object.const_get(ENV['STORAGE_CONTAINER']).builder
Seeds.call unless ENV['RACK_ENV'] == 'test'

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
    typos = Typo.all_for(user)
    """
    <p>Welcome #{session[:uid]}!</p>

    <ul>
      <li><a href=\"/admin/typos\">Check out #{typos.size} Reported Typos</a></li>
      <li><a href=\"/admin/sites\">Manage Sites</a></li>
    </ul>
    """
  end

  get '/admin/typos' do
    typos = Typo.all_for(user).map do |typo|
      "<li>#{typo.contents} at around #{typo.context}</li>"
    end
    "<ul>#{typos.join}</ul>"
  end

  get '/admin/typos/:fingerprint' do
  end

  get '/admin/sites' do
  end

  post '/admin/sites' do
  end

  delete '/admin/sites/:token' do
  end

  # Typo Submission
  post '/typos/:token' do
    site = Site.find(params[:token])
    not_found unless site.valid?
    WorkQueue.add(Workers::TypoReport, params[:typo].merge(token: site.token))
    status 201
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

