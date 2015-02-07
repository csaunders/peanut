$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'sinatra/base'
require 'sinatra/flash'
require 'sinatra/reloader'
require 'rack/cors'
require 'omniauth'
require 'omniauth-google-oauth2'
require 'dotenv'

require 'lib/storage'
require 'lib/workers'
require 'user'
require 'typo'
require 'site'
require 'auth'
require 'seeds'

Dotenv.load
Storage.factory = Object.const_get(ENV['STORAGE_CONTAINER']).builder
Seeds.call unless ENV['RACK_ENV'] == 'test'

class PeanutApp < Sinatra::Base
  register Sinatra::Flash

  configure :development do
    register Sinatra::Reloader
  end

  use Rack::MethodOverride
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
  before '/admin*' do
    authenticate!
  end

  get '/admin' do
    @typos = Typo.all_for(user)
    admin_layout 'admin/index'
  end

  get '/admin/typos' do
    @typos = Typo.all_for(user)
    admin_layout 'admin/typos/index'
  end

  get '/admin/typos/:fingerprint' do
  end

  get '/admin/sites' do
    @sites = Site.all_for(user)
    admin_layout 'admin/sites/index'
  end

  get '/admin/sites/new' do
    admin_layout 'admin/sites/new'
  end

  post '/admin/sites' do
    site = Site.new(owner: user, url: params[:url])
    if site.valid? && site.save
      flash[:notice] = "Successfully Added #{site.url}"
      redirect to("/admin/sites")
    else
      flash[:error] = site.errors
      redirect to('/admin/sites/new')
    end
  end

  delete '/admin/sites/:token' do
    site = Site.find_for(user, params[:token])
    site.remove
    flash[:notice] = "Removed typo reporting for #{site.url}"
    redirect to('/admin/sites')
  end

  get '/admin/sites/:token/edit' do
    @site = Site.find_for(user, params[:token])
    admin_layout "admin/sites/edit"
  end

  put '/admin/sites/:token' do
    @site = Site.find_for(user, params[:token])
    @site.url = params[:url]
    @site.save
    redirect to("/admin/sites/#{site.token}")
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

  def admin_layout(template)
    erb template.to_sym, layout: :admin
  end
end

