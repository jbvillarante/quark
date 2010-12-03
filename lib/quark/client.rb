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

    def create_session_from_token(token)
      response = Quark::SignedRequest.post(@settings[:endpoint], 'session', @settings[:api_secret ], :params => { :api_key => @settings[:api_key], :auth_token => token })
      session_key = Nokogiri::XML(response.body).css('session_key').text
      uid = Nokogiri::XML(response.body).css('uid').text
      create_session(:session_key => session_key, :uid => uid)
    end

    def create_session(params)
      Quark::Session.new(:api_key => @settings[:api_key], :api_secret => @settings[:api_secret], :endpoint => @settings[:endpoint], :session_key => params[:session_key], :uid => params[:uid])
    end
  end
end
