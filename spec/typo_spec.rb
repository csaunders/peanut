require 'storage'
require 'typo'
require 'user'

RSpec.describe 'Typo' do
  before(:each) do
    Storage.factory = ->(){ MemoryStorage.new }
  end

  after(:each) do
    MemoryStorage.clear!
    Storage.factory = nil
  end

  let(:storage) { MemoryStorage.new }
  let(:user) { object_double(User.new('alakazam'), uid: 'alakazam')}
  let(:typo) { Typo.new(owner: user, contents: 'charmndr', url: 'http://example.com/article', fingerprint: 'abracadabra', context: 'You have discovered <typo>. Charmander is a fire type pokemon.')}

  describe '#all_for' do
    it "should return all the typos for a user" do
      typo.save
      expect(Typo.all_for(user)).to eq([typo])
    end
  end

  describe '#unmarshal' do
  end

  describe '.initialize' do
    it 'sets the contents of the typo' do
      typo = Typo.new(contents: 'Hello World')
      expect(typo.contents).to eq('Hello World')
    end

    it 'sets the url of the typo' do
      typo = Typo.new(url: 'http://example.com/foobar')
      expect(typo.url).to eq('http://example.com/foobar')
    end

    it 'sets the context of the typo' do
      typo = Typo.new(context: 'this is where your <typo> was')
      expect(typo.context).to eq('this is where your <typo> was')
    end

  end

  describe '.fingerprint_contents' do
    it 'creates a string to create fingerprints from' do
      typo = Typo.new(context: 'hi there', url: 'whatever', contents: 'foobar')
      expect(typo.fingerprint_contents).to eq('foobar:hi there:whatever')
    end

    xit 'trims out unnecessary URL parameters' do
    end
  end

  describe '.fingerprint' do
    it 'has a set of required fields for fingerprint generation' do
      expect(Typo::RequiredFields).to eq(%i(context url contents).sort)
    end

    it 'does not generate a sha if the required fingerprinting attributes are missing' do
      typo = Typo.new(context: 'hello <typo>!!', url: 'http://example.com/foobar')
      expect(typo.fingerprint).to be_nil
    end

    it 'generates a fingerprint' do
      typo = Typo.new(context: 'hello <typo> fancy', url: 'http://example.com/foobar', contents: 'wolrd')
      expect(typo.fingerprint).to eq('3a70f0ed327595647d02230f6d7685c408955fc292b2d0d62e94a94ac3118841')
    end

    it 'does not generate a fingerprint if one is already generated' do
      typo = Typo.new(context: 'hello <typo>!!', url: 'http://example.com/foobar', contents: 'wolrd', fingerprint: 'hello')
      expect(typo.fingerprint).to eq('hello')
    end
  end

  describe 'unique?' do
    it 'is unique if a record with the same fingerprint does not exist in storage' do
      expect(typo.unique?).to be_truthy
    end

    it 'is not unique if a record with the same fingerprint is already in storage' do
      expect(typo.save).to be_truthy
      expect(Typo.new(owner: user, fingerprint: typo.fingerprint, url: '', contents: '', context: '').unique?).to be_falsy
    end
  end


  describe '.to_hash' do
  end

  describe '.marshal' do
  end

  describe '.save' do
    context 'when the data is valid' do
      it 'adds an entry to the users typos set' do
        typo = Typo.new(context: 'hello <typo>!!', url: 'http://example.com/foobar', contents: 'wolrd', fingerprint: 'hello', owner: user)
        expect(typo.save).to be_truthy
        expect(storage.get("typos:#{user.uid}").size).to be(1)
      end

      it 'does not add an entry if the data already exists' do
        Typo.new(context: 'hello <typo>!!', url: 'http://example.com/foobar', contents: 'wolrd', fingerprint: 'hello', owner: user).save
        typo = Typo.new(context: 'hello <typo>!!', url: 'http://example.com/foobar', contents: 'wolrd', fingerprint: 'hello', owner: user)
        expect(typo.save).to be_falsy
        expect(storage.get("typos:#{user.uid}").size).to be(1)
      end
    end

    it 'does not save if it does not have an owner' do
      typo = Typo.new(context: 'hello <typo>!!', url: 'http://example.com/foobar', contents: 'wolrd', fingerprint: 'hello')
      expect(typo.save).to be_falsy
    end
  end
end
