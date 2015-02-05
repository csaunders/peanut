class MemoryStorage
  class ValueError < StandardError; end

  def self.builder
    ->(){ MemoryStorage.new }
  end

  def self.clear!
    @@storage = {}
  end

  def initialize
    @@storage ||= {}
  end

  def append(key, value, *others)
    storage[key] ||= []
    raise ValueError, "Value for #{key} is not a collection type" unless storage[key].is_a?(Array)
    (others || []).unshift(value).each do |v|
      storage[key] << v
    end
  end

  def remove(key, value, *others)
    raise ValueError, "Value for #{key} is not a collection type" unless storage[key].is_a?(Array)
    result = (others || []).unshift(value).map do |v|
      storage[key].delete(v)
    end
    storage.delete(key) if storage[key].empty?
    result
  end

  def set(key, value)
    raise ValueError, "Cannot set nil values for keys, use del(key) to remove a key" if value.nil?
    raise ValueError, "Cannot set collection types, use append(key, value) instead" if value.is_a?(Array)
    storage[key] = value
  end

  def get(key)
    storage[key]
  end

  def del(key)
    storage.delete(key)
  end

  def exec(&blk)
    instance_eval(&blk)
  end

  def empty?
    storage.empty?
  end

  private
  def storage
    @@storage
  end
end
