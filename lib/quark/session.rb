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
      JSON.parse(response.body)['album']
    end
    
    def photos(album_id)
      response = get(:resource => 'photos', :params => {:aid => album_id} )
      JSON.parse(response.body)['photo']
    end
    
    def photo(photo_id)
      response = get(:resource => "photo/#{photo_id}")
      JSON.parse(response.body)['photo']
    end
    
    def primary_photo
      response = get(:resource => "primaryphoto/#{uid}")
      JSON.parse(response.body)['photo']
    end
    
    def user
      response = get(:resource => 'user')
      JSON.parse(response.body)['user']
    end
      
    def get(data)
      Quark::SignedRequest.get(endpoint, data[:resource], @settings[:api_secret], :params => build_params(data[:params]))
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
