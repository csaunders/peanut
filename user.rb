require 'storage'

class User
  attr_accessor :uid
  def self.find(uid)
    Storage.connect do |conn|
      user = User.new(uid)
      conn.get(user.key) ? user : nil
    end
  end

  def initialize(uid)
    @uid = uid
  end

  def save
    Storage.connect do |conn|
      conn.set(key, true)
    end
  end

  def key
    "users:#{@uid}"
  end
end
