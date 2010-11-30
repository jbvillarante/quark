require 'nokogiri'

module Quark
  class Client
    def initialize(params)
      @settings = {
        :endpoint => 'http://api.friendster.com/v1',
        :api_key => nil,
        :api_secret => nil
      }.merge(params)

      raise ArgumentError, 'Missing required parameter: api_key' if @settings[:api_key] == nil
      raise ArgumentError, 'Missing required parameter: api_secret' if @settings[:api_secret] == nil
    end

    def api_key
      @settings[:api_key]
    end

    def endpoint
      @settings[:endpoint]
    end

    def get_token
      response = Quark::UnsignedRequest.post(@settings[:endpoint], 'token', :params => { :api_key => @settings[:api_key] })
      Nokogiri::XML(response.body).css("auth_token").text
    end
  end
end
