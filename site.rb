require 'securerandom'
require 'json'

class Site
  class SerializationError < StandardError; end

  attr_accessor :url, :owner, :token

  def self.all_for(owner, limit: [0, 10])
    Storage.connect do |conn|
      sites = conn.get("sites:#{owner.uid}") || []
      sites.map do |token|
        find_for_with_connection(owner, token, conn)
      end
    end
  end

  def self.find(token)
    Storage.connect do |conn|
      unmarshal(conn.get("sites:#{token}") || "")
    end
  end

  def self.find_for(owner, token)
    Storage.connect { |c| find_for_with_connection(owner, token, c)}
  end

  def self.find_for_with_connection(owner, token, conn)
    key = "sites:#{token}"
    json = conn.get(key)
    unmarshal(json).tap { |s| s.owner = owner } if json
  end

  def self.unmarshal(site_json)
    data = if site_json && site_json.length > 0
      JSON.parse(site_json)
    else
      {}
    end
    Site.new(data)
  end

  def initialize(args)
    args.each do |k,v|
      public_send("#{k}=", v) if respond_to?(k)
    end
    self.token ||= generate_token
  end

  def to_hash
    validate!
    {url: url, token: token}
  end

  def marshal
    to_hash.to_json
  end

  def save
    Storage.transaction do |conn|
      conn.set("sites:#{token}", marshal)
      conn.append("sites:#{owner.uid}", token)
    end
  end

  def remove
    Storage.transaction do |conn|
      conn.del("sites:#{token}")
      conn.remove("sites:#{owner.uid}", token)
    end
  end

  def ==(other)
    [:owner, :url, :token].all? { |k| self.public_send(k) == other.public_send(k) }
  end

  def valid?
    errors.empty?
  end

  def errors
    errors = []
    errors << "Url cannot be blank" unless url
    errors << "Token cannot be blank" unless token
    errors
  end

  private
  def validate!
    raise SerializationError, "Invalid Site:\n#{errors.join("\n")}" unless errors.empty?
  end

  def generate_token
    SecureRandom.hex
  end
end
