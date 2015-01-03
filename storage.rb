require 'redis'
require 'connection_pool'

class Storage
  def self.default_factory
    ->(){ Redis.new }
  end

  def self.factory
    @@factory || default_factory
  end

  def self.factory=(factory)
    @@factory = factory
  end

  def self.connect
    raise "Cannot make connections outside of block" unless block_given?
    new.pool.with { |conn| yield(conn) }
  end

  def self.transaction
    connect do |conn|
      conn.multi do |multi|
        yield(multi)
      end
    end
  end

  def pool
    $redis ||= ConnectionPool.new(size: ENV['MAX_CONNECTIONS'].to_i, timeout: ENV['CONNECTION_TIMEOUT'].to_i) do
      Storage.factory.call
    end
  end
end
