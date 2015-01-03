require 'digest'

class Typo
  attr_accessor :context, :contents, :url, :fingerprint, :owner

  RequiredFields = %i(contents context url).sort

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
end
