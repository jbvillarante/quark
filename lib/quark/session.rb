require 'json'

module Quark
  class Session
    def initialize(params)
      @settings = {
        :endpoint => 'http://api.friendster.com/v1',
        :api_key => nil,
        :api_secret => nil,
        :session_key => nil,
        :format => 'json'
      }.merge(params)

      [ :api_key, :api_secret, :session_key, :uid ].each do |required|
        raise ArgumentError, "Missing required parameter: #{required}" if @settings[required] == nil
      end
    end

    def endpoint
      return @settings[:endpoint]
    end

    def session_key
      return @settings[:session_key]
    end

    def uid
      return @settings[:uid]
    end

    def albums
      response = Quark::SignedRequest.get(endpoint, 'albums', @settings[:api_secret], :params => @settings)
      JSON.parse(response.body)['album']
    end
    
    def photos(album_id)
      params = @settings.merge(:aid => album_id)
      response = Quark::SignedRequest.get(endpoint, 'photos', @settings[:api_secret], :params => params)
      JSON.parse(response.body)['photo']
    end
    
    def photo(photo_id)
      params = @settings.merge(:pid => photo_id)
      response = Quark::SignedRequest.get(endpoint, "photo/#{photo_id}", @settings[:api_secret], :params => params)
      JSON.parse(response.body)['photo']
    end
  end
end
