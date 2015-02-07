require 'storage'
class WorkQueue
  def self.add(worker, data)
    Storage.connect do |conn|
      conn.append(:queue, {worker: worker, data: data})
    end
  end
end
