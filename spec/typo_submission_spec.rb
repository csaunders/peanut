ENV['RACK_ENV'] = 'test'
require 'application'
require 'storage'
require 'rack/test'

RSpec.describe 'Application' do
  include Rack::Test::Methods
  def app
    PeanutApp
  end

  before(:each) do
    Storage.factory = ->(){ MemoryStorage.new }
  end

  after(:each) do
    MemoryStorage.clear!
  end

  let(:submission) { {contents: 'hello', url: 'http://example.com', context: '<typo> world!'} }
  let(:storage) { MemoryStorage.new }

  it "should be able to get the root" do
    get '/'
    expect(last_response.status).to eq(200)
  end

  describe 'typo submission' do
    context 'when the UUID is invalid' do

      it 'should not submit the data for processing' do
        expect(storage.get(:queue)).to be_falsy
        post '/typos/invalid-uuid', typo: submission
        expect(storage.get(:queue)).to be_falsy
      end

      it 'should return a 404' do
        post '/typos/invalid-uuid', typo: submission
        expect(last_response.status).to eq(404)
      end
    end

    context 'when the UUID is valid' do
      let(:owner) { User.new('abracadabra') }
      let(:site) { Site.new(url: 'http://example.com', owner: owner, token: 'something')}

      before(:each) do
        owner.save
        site.save
      end

      it 'should submit the data for processing' do
        expect(storage.get(:queue)).to be_falsy
        post "/typos/#{site.token}", typo: submission
        expect(storage.get(:queue).length).to eq(1)
      end

      it 'should return a 201' do
        post "/typos/#{site.token}", typo: submission
        expect(last_response.status).to eq(201)
      end

      it 'should submit the data for processing even if the typo has already been submitted' do
        post "/typos/#{site.token}", typo: submission
        post "/typos/#{site.token}", typo: submission
        expect(storage.get(:queue).length).to eq(2)
      end
    end
  end
end
