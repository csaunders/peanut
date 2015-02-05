require 'user'
require 'typo'

Seeds = Proc.new do
  puts "---------- Seeding Database ----------"
  user = User.new("106612259365671384043")
  user.save

  Typo.new(owner: user, context: 'dunnolol', contents: 'abracadabra', url: 'http://example.com').save
  Typo.new(owner: user, context: 'ohai', contents: 'abracadabra', url: 'http://example.com').save
  Typo.new(owner: user, context: 'hello', contents: 'abracadabra', url: 'http://example.com').save
  Typo.new(owner: user, context: 'goodbye', contents: 'abracadabra', url: 'http://example.com').save
  Typo.new(owner: user, context: 'farewell', contents: 'abracadabra', url: 'http://example.com').save
  Typo.new(owner: user, context: 'aloha', contents: 'abracadabra', url: 'http://example.com').save
  puts "---------- Seeding Complete ----------"
end
