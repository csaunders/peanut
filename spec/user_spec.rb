require 'storage'
require 'user'

RSpec.describe "User" do
  before(:each) do
    Storage.factory = ->(){ MockStorage.new }
  end

  after(:each) do
    MockStorage.clear!
    Storage.factory = nil
  end

  let(:storage) { MockStorage.new }
  let(:uid) { "abracadabra" }

  describe '#find' do
    context 'when a user exists' do
      it do
        storage.container['users:abracadabra'] = true
        expect(User.find(uid)).not_to be_nil
      end
    end

    context 'when a user does not exist' do
      it { expect(User.find(uid)).to be_nil }
    end
  end

  describe '.save' do
    context 'when user has a UID' do
      it 'persists the user data to storage' do
        user = User.new('alakazam')
        expect(user.save).to be(true)
        expect(storage.container['users:alakazam']).to be(true)
      end
    end
  end
end
