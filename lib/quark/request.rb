require 'typhoeus'
require 'digest/md5'

module Quark
  class Exception < StandardError
    attr_reader :response
    def initialize(response)
      @response = response
      begin
        json = JSON.parse(response.body)
        @code = json['error_code']
        @message = json['error_msg']
      rescue JSON::ParserError
        begin
          xml = Nokogiri::XML.parse(response.body) { |config| config.strict }
          @code = xml.at_css('error_code').text
          @message = xml.at_css('error_msg').nil? ? xml.at_css('error_message').text : xml.at_css('error_msg').text
        rescue Nokogiri::XML::SyntaxError
          @code = '0xdeadbeef'
          @message = 'Could not read the error response from the server'
        end
      end
    end

    def to_s
      "#{@code}: #{@message}"
    end
  end

  class UnsignedRequest < Typhoeus::Request
    def self.post(endpoint, resource, options)
      check_for_errors(super("#{endpoint}/#{resource}", options))
    end

    def self.get(endpoint, resource, options)
      check_for_errors(super("#{endpoint}/#{resource}", options))
    end

    def self.check_for_errors(response)
      if response.code == 200
        response
      else
        raise Quark::Exception.new(response)
      end
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
