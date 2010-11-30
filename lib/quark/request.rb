require 'typhoeus'
require 'digest/md5'

module Quark
  class UnsignedRequest < Typhoeus::Request
    def self.post(endpoint, resource, options)
      super("#{endpoint}/#{resource}", options)
    end

    def self.get(endpoint, resource, options)
      super("#{endpoint}/#{resource}", options)
    end
  end

  class SignedRequest < Quark::UnsignedRequest
    def self.post(endpoint, resource, secret_key, options)
      options[:params].merge!({ :sig => signature(endpoint, resource, secret_key, options[:params]) })
      super(endpoint, resource, options)
    end

    def self.get(endpoint, resource, secret_key, options)
      options[:params].merge!({ :sig => signature(endpoint, resource, secret_key, options[:params]) })
      super(endpoint, resource, options)
    end

    def self.signature(endpoint, resource, secret_key, options)
      Digest::MD5.hexdigest([ URI.parse("#{endpoint}/#{resource}").path,
        options.keys.sort_by { |key| key.to_s }.map { |key|
          "#{key.to_s}=#{options[key]}"
        },
        secret_key ].flatten.join)
    end
  end
end
