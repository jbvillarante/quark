require 'curb'
require 'cgi'
require 'digest/md5'

module Quark
  class Exception < StandardError
    attr_reader :response, :error_code, :error_message
    def initialize(response)
      @response = response
      begin
        json = JSON.parse(response.body_str)
        @error_code = json['error_code']
        @error_message = json['error_msg']
      rescue JSON::ParserError
        begin
          xml = Nokogiri::XML.parse(response.body_str) { |config| config.strict }
          @error_code = xml.at_css('error_code').text
          @error_message = xml.at_css('error_msg').nil? ? xml.at_css('error_message').text : xml.at_css('error_msg').text
        rescue Nokogiri::XML::SyntaxError
          @error_code = '0xdeadbeef'
          @error_message = 'Could not read the error response from the server'
        end
      end
    end

    def to_s
      "#{error_code}: #{error_message}"
    end
  end

  class UnsignedRequest
    def self.post(endpoint, resource, options)
      post_data = options[:params].map{|key, value| Curl::PostField.content(key.to_s, value)}
      check_for_errors(Curl::Easy.http_post("#{endpoint}/#{resource}", *post_data))
    end

    def self.get(endpoint, resource, options)
      get_params = options[:params].map{|k,v| "#{CGI.escape(k.to_s)}=#{CGI.escape(v)}"}.join('&')
      check_for_errors(Curl::Easy.http_get("#{endpoint}/#{resource}?#{get_params}"))
    end
    
    def self.put(endpoint, resource, options)
      put_data = options[:params].map{|k,v| "#{CGI.escape(k.to_s)}=#{CGI.escape(v)}"}.join('&')
      check_for_errors(Curl::Easy.http_put("#{endpoint}/#{resource}", put_data){|c| c.headers['Content-Type'] = 'application/x-www-form-urlencoded'})
    end

    def self.check_for_errors(response)
      if response.response_code == 200
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
    
    def self.put(endpoint, resource, secret_key, options)
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
