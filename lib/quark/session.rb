require 'json'

module Quark
  class Session
    def initialize(params)
      @settings = {
        :endpoint => 'http://api.friendster.com/v1'
      }.merge(params)

      [ :api_key, :api_secret, :session_key, :uid ].each do |required|
        raise ArgumentError, "Missing required parameter: #{required}" if @settings[required] == nil
      end
    end

    def endpoint
      @settings[:endpoint]
    end

    def session_key
      @settings[:session_key]
    end

    def uid
      @settings[:uid]
    end

    def albums
      response = get(:resource => 'albums')
      JSON.parse(response.body_str)['album']
    end
    
    def photos(album_id = nil)
      params = { :resource => 'photos' }
      params.merge!(:params => { :aid => album_id }) unless album_id == nil
      response = get(params)
      json_object = JSON.parse(response.body_str)
      json_object.empty? ? json_object : json_object['photo']
    end
    
    def photo(photo_id)
      response = get(:resource => "photo/#{photo_id}")
      JSON.parse(response.body_str)['photo']
    end
    
    def primary_photo
      response = get(:resource => "primaryphoto/#{uid}")
      JSON.parse(response.body_str)['photo']
    end
    
    def user(ids = nil)
      resource = case
        when ids.is_a?(Array)
          "user/#{ids.join(',')}"
        when ids.is_a?(String) || ids.is_a?(Integer)
          "user/#{ids}"
        else
          'user'
      end
      response = get(:resource => resource)
      JSON.parse(response.body_str)['user']
    end
      
    def get(data)
      Quark::SignedRequest.get(endpoint, data[:resource], @settings[:api_secret], :params => build_params(data[:params]))
    end
    
    def post(data)
      Quark::SignedRequest.post(endpoint, data[:resource], @settings[:api_secret], :params => build_params(data[:params]))
    end
    
    def put(data)
      Quark::SignedRequest.put(endpoint, data[:resource], @settings[:api_secret], :params => build_params(data[:params]))
    end
    
    private
    def build_params(options)
      options ||= {}
      params = {
        :api_key => @settings[:api_key],
        :session_key => session_key,
        :nonce => "#{Time.now.to_f}", 
        :format => 'json'
      }.merge(options)
    end
  end
end
