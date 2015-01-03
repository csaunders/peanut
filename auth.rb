class Auth
  attr_reader :session

  def initialize(session)
    @session = session
  end

  def login(auth_hash)
    session[:uid] = auth_hash[:uid]
  end

  def logout
    session.clear
  end

end
