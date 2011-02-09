require 'json'

module Quark
  class Client
    def initialize(params)
      @settings = {
        :endpoint => 'http://api.friendster.com/v1'
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
      response = Quark::SignedRequest.post(@settings[:endpoint], 'token', @settings[:api_secret ], :params => { :api_key => @settings[:api_key], :format => 'json', signed_keys: "api_key,format,signed_keys" })
      eval(response.body_str)
    end
    
    def login(email, password)
      response = Quark::SignedRequest.post(@settings[:endpoint], 'login', @settings[:api_secret ], :params => { :api_key => @settings[:api_key], :user_email => email, :user_pwd => password, :auth_token => get_token, :format => 'json', signed_keys: "api_key,user_email,user_pwd,auth_token,format,signed_keys" })
      options = JSON.parse(response.body_str)
      create_session(:session_key => options['session_key'], :uid => options['uid'])
    end

    def create_session_from_token(token)
      raise ArgumentError, 'Token should not be nil' if token == nil
      response = Quark::SignedRequest.post(@settings[:endpoint], 'session', @settings[:api_secret ], :params => { :api_key => @settings[:api_key], :auth_token => token, :format => 'json', signed_keys: "api_key,auth_token,signed_keys,format" })
      options = JSON.parse(response.body_str)
      create_session(:session_key => options['session_key'], :uid => options['uid'])
    end

    def create_session(params)
      Quark::Session.new(:api_key => @settings[:api_key], :api_secret => @settings[:api_secret], :endpoint => @settings[:endpoint], :session_key => params[:session_key], :uid => params[:uid])
    end
  end
end
