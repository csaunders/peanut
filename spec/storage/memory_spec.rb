require 'storage/memory'

RSpec.describe 'MemoryStorage' do
  class ExposedMemoryStorage < MemoryStorage
    def self.storage
      @@storage
    end

    def self.storage=(container)
      @@storage = container
    end
  end

  before(:example) { MemoryStorage.clear! }
  let(:storage) { MemoryStorage.new }


  describe 'set' do
    it 'should set the value if it does not already exist' do
      expect(ExposedMemoryStorage.storage).to eq({})
      storage.set('hello', 'world')
      expect(ExposedMemoryStorage.storage).to eq({'hello' => 'world'})
    end

    it 'should overwrite the preexisting value if it already exists' do
      ExposedMemoryStorage.storage = {'hello' => 'world'}
      storage.set('hello', 'goodbye')
      expect(ExposedMemoryStorage.storage).to eq({'hello' => 'goodbye'})
    end

    it 'should raise an error if trying to set a key to nil' do
      expect{storage.set('hello', nil)}.to raise_error(MemoryStorage::ValueError)
    end

    it 'should raise an error if trying to set a key to an array' do
      expect{storage.set('hello', %w(why hello))}.to raise_error(MemoryStorage::ValueError)
    end
  end

  describe 'get' do
    it 'should return nil if the value does not exist' do
      expect(storage.get('hello')).to be_nil
    end

    it 'should return the value stored for a key if it exists' do
      ExposedMemoryStorage.storage = {'hello' => 'world'}
      expect(storage.get('hello')).to eq('world')
    end
  end

  describe 'del' do
    it 'should remove the data associated with the key' do
      ExposedMemoryStorage.storage = {'hello' => 'world'}
      storage.del('hello')
      expect(ExposedMemoryStorage.storage).to eq({})
    end

    it 'should return the data that was associated with the removed key' do
      ExposedMemoryStorage.storage = {'hello' => 'world'}
      expect(storage.del('hello')).to eq('world')
    end

    it 'should return nil if the key did not exist in storage' do
      expect(storage.del('hello')).to be_nil
    end
  end

  describe 'append' do
    it 'should create an array and add the data to it the key was not already set' do
      storage.append('hello', 'world')
      expect(ExposedMemoryStorage.storage).to eq({'hello' => %w(world)})
    end

    it 'should append the data to the array if the key and array already exist' do
      ExposedMemoryStorage.storage = {'hello' => %w(world)}
      storage.append('hello', 'again')
      expect(ExposedMemoryStorage.storage).to eq({'hello' => %w(world again)})
    end

    it 'should append multiple values to the array in a single call' do
      storage.append('hello', 'again', 'fine', 'people')
      expect(ExposedMemoryStorage.storage).to eq({'hello' => %w(again fine people)})
    end

    it 'should return the items that were appended if multiple called with multiple values' do
      expect(storage.append('hello', 'again', 'fine', 'people')).to eq(%w(again fine people))
    end

    it 'should raise an error if the value for the key is not already an array' do
      ExposedMemoryStorage.storage = {'hello' => 'world'}
      expect{storage.append('hello', 'again')}.to raise_error(MemoryStorage::ValueError)
    end
  end

  describe 'remove' do
    it 'should remove the data from the array' do
      ExposedMemoryStorage.storage = {'hello' => %w(world again)}
      storage.remove('hello', 'again')
      expect(ExposedMemoryStorage.storage).to eq({'hello' => %w(world)})
    end

    it 'should remove the key from storage if the array becomes empty' do
      ExposedMemoryStorage.storage = {'hello' => %w(world)}
      storage.remove('hello', 'world')
      expect(ExposedMemoryStorage.storage).to eq({})
    end

    it 'should remove multiple values in a single call' do
      ExposedMemoryStorage.storage = {'hello' => %w(world my friends)}
      storage.remove('hello', 'world', 'friends')
      expect(ExposedMemoryStorage.storage).to eq({'hello' => %w(my)})
    end

    it 'should include nils for the objects that could not be removed during multiple removal' do
      ExposedMemoryStorage.storage = {'hello' => %w(world my friends)}
      expect(storage.remove('hello', 'world', 'some', 'people', 'friends')).to eq(['world', nil, nil, 'friends'])
    end

    it 'should return the value of the data that was removed' do
      ExposedMemoryStorage.storage = {'hello' => %w(world)}
      expect(storage.remove('hello', 'world')).to eq(['world'])
    end

    it 'should return nil if the data did not exist in the array' do
      ExposedMemoryStorage.storage = {'hello' => %w(world)}
      expect(storage.remove('hello', 'something')).to eq([nil])
    end

    it 'should raise an error if the value for the key is not an array' do
      ExposedMemoryStorage.storage = {'hello' => 'world'}
      expect{storage.remove('hello', 'world')}.to raise_error(MemoryStorage::ValueError)
    end
  end

  describe 'empty?' do
    it 'should return true if storage contains nothing' do
      ExposedMemoryStorage.storage = {}
      expect(storage.empty?).to be(true)
    end

    it 'should return false if storage contains something' do
      ExposedMemoryStorage.storage = {'key' => 'value'}
      expect(storage.empty?).to be(false)
    end
  end

  describe 'exec' do
    it 'should run multiple commands' do
      storage.exec do
        set('hello', 'world')
        append('players', 'john')
        append('players', 'jane')
      end
      expected_storage = {
        'hello' => 'world',
        'players' => %w(john jane)
      }
      expect(ExposedMemoryStorage.storage).to eq(expected_storage)
    end
  end
end
