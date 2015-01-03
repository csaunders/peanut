require 'storage'
require 'site'
require 'user'

RSpec.describe 'Site' do
  before(:each) do
    Storage.factory = ->(){ MockStorage.new }
  end

  after(:each) do
    MockStorage.clear!
    Storage.factory = nil
  end

  let(:storage) { MockStorage.new }
  let(:user) { object_double(User.new('abracadabra'), uid: 'abracadabra')}
  let(:site) { Site.new(owner: user, url: 'http://example.com', token: 'slowpoke') }

  describe '#all_for' do
    context 'user has no sites stored' do
      it 'returns an empty array' do
        expect(Site.all_for(user)).to eq([])
      end
    end

    context 'user who has sites stored' do
      it 'returns an array of sites' do
        storage.container['sites:abracadabra'] = [site.token]
        storage.container["sites:#{site.token}"] = site.marshal
        expect(Site.all_for(user)).to eq([site])
      end
    end

    context 'user who has many sites stored' do
      xit 'returns a subset of the sites'
    end
  end

  describe '#find_for' do
    context 'user who owns the site' do
      let(:site2) { Site.new(owner: user, url: 'http://other.example.com', token: 'gengar') }
      it 'gives the user site details' do
        storage.container['sites:abracadabra'] = [site.token, site2.token]
        storage.container["sites:#{site2.token}"] = site2.marshal
        expect(Site.find_for(user, 'gengar')).to eq(site2)
      end
    end

    context 'user who does not own the site' do
      it 'gives the user nothing' do
        user = User.new(uid: 'gary')
        expect(Site.find_for(user, 'gengar')).to be_nil
      end
    end
  end

  describe '#unmarshal' do
    it 'creates a new site object from the JSON string' do
      site = Site.unmarshal('{"url":"http://example.com","token":"slowpoke"}')
      expect(site.url).to eq('http://example.com')
      expect(site.token).to eq('slowpoke')
    end
  end

  describe '.initialize' do
    it 'sets the URL for the site' do
      site = Site.new(url: 'http://example.com')
      expect(site.url).to eq('http://example.com')
    end

    it 'sets the token for the site' do
      site = Site.new(token: 'slowpoke')
      expect(site.token).to eq('slowpoke')
    end

    it 'assigns the token if one is not provided' do
      site = Site.new({})
      expect(site.token).not_to be_nil
    end
  end

  describe '.to_hash' do
    it 'creates a hash from the object' do
      expect(site.to_hash).to eq(url: 'http://example.com', token: 'slowpoke')
    end

    it 'raises an error if required hash data is missing' do
      site.url = nil
      expect{site.to_hash}.to raise_error(Site::SerializationError)
    end
  end

  describe '.marshal' do
    it 'turns the site data into JSON' do
      expect(site.marshal).to eq('{"url":"http://example.com","token":"slowpoke"}')
    end
  end

  describe '.save' do
    it 'adds an entry to the users sites set' do
      expect(Site.all_for(user)).to be_empty
      site = Site.new(owner: user, url: 'http://example.com')
      site.save
      expect(Site.all_for(user)).to eq([site])
    end
  end
end
