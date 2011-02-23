require 'curb'
require 'nokogiri'
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
    attr_reader :curl

    def initialize(url, options={})
      @curl = Curl::Easy.new(url)
      options.each do |curl_option, curl_option_value|
        curl.send("#{curl_option}=", curl_option_value)
      end
    end

    def self.post(endpoint, resource, options)
      curl_options = {
        :post_body => urlencoded_params(options[:params])
      }.merge(options[:curl_options] || {})
      request = new("#{endpoint}/#{resource}", curl_options)
      request.http(:POST)
    end

    def self.get(endpoint, resource, options)
      request = new("#{endpoint}/#{resource}?#{urlencoded_params(options.delete(:params))}", options[:curl_options] || {})
      request.http(:GET)
    end
    
    def self.put(endpoint, resource, options)
      curl_options = {
        :headers => { 'Content-Type' => 'application/x-www-form-urlencoded' },
        :put_data => urlencoded_params(options[:params])
      }.merge(options[:curl_options] || {})
      request = new("#{endpoint}/#{resource}", curl_options)
      request.http(:PUT)
    end

    def http(verb)
      curl.http(verb)
      curl.response_code == 200 ? curl : raise(Quark::Exception.new(curl))
    end

    private

    def self.urlencoded_params(params)
      params.map{|k,v| "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}"}.join('&')
    end
  end

  class SignedRequest < Quark::UnsignedRequest
    def self.post(endpoint, resource, secret_key, options)
      options[:params][:signed_keys] = (options[:params].keys + [:signed_keys]).join(',')
      options[:params].merge!({ :sig => Quark::Util.signature("#{endpoint}/#{resource}", secret_key, options[:params]) })
      super(endpoint, resource, options)
    end

    def self.get(endpoint, resource, secret_key, options)
      options[:params][:signed_keys] = (options[:params].keys + [:signed_keys]).join(',')
      options[:params].merge!({ :sig => Quark::Util.signature("#{endpoint}/#{resource}", secret_key, options[:params]) })
      super(endpoint, resource, options)
    end
    
    def self.put(endpoint, resource, secret_key, options)
      options[:params][:signed_keys] = (options[:params].keys + [:signed_keys]).join(',')
      options[:params].merge!({ :sig => Quark::Util.signature("#{endpoint}/#{resource}", secret_key, options[:params]) })
      super(endpoint, resource, options)
    end
  end
end
