class MockStorage
  @@container = {}

  def self.clear!
    @@container = {}
  end

  def container
    @@container
  end

  def get(key)
    @@container[key]
  end

  def set(key, data)
    @@container[key] = data
  end

  def sort(key, options)
    @@container[key] || Set.new
  end

  def sadd(key, value)
    @@container[key] ||= Set.new
    @@container[key].add(value)
  end

  def srem(key, value)
    @@container[key] ||= Set.new
    @@container[key].delete(value)
  end

  def multi
    yield(self)
  end

end
