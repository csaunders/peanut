require 'digest'

class Typo
  attr_accessor :context, :contents, :url, :owner
  attr_writer :fingerprint

  RequiredFields = %i(contents context url).sort

  def self.all_for(user)
    results = []
    Storage.connect do |conn|
      results = conn.get("typos:#{user.uid}").map do |fingerprint|
        conn.get("typos:#{user.uid}:#{fingerprint}")
      end
    end
  end

  def initialize(args={})
    args.each do |k,v|
      public_send("#{k}=", v) if respond_to?(k)
    end
  end

  def fingerprint
    return unless RequiredFields.none? { |f| public_send(f).nil? }
    @fingerprint ||= begin
      Digest::SHA256.hexdigest(fingerprint_contents)
    end
  end

  def fingerprint_contents
    RequiredFields.map { |f| public_send(f) }.join(':')
  end

  def unique?
    Storage.connect do |conn|
      conn.get("typos:#{owner.uid}:#{fingerprint}").nil?
    end
  end

  def save
    return unless owner && unique?
    Storage.connect do |conn|
      conn.set("typos:#{owner.uid}:#{fingerprint}", self)
      conn.append("typos:#{owner.uid}", fingerprint)
    end
    true
  end
end
