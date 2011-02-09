require 'json'

module Quark
  class Session
    def self.from_friendster(callback_url, api_secret, params)
      raise Quark::InvalidSignatureError if params[:sig] != signature(callback_url, api_secret, params)
      Session.new(api_secret: api_secret, api_key: params[:api_key], session_key: params[:session_key], uid: params[:user_id], endpoint: params[:endpoint])
    end

    def initialize(params)
      @settings = {
        :endpoint => 'http://api.friendster.com/v1'
      }.merge(params)

      [ :api_key, :api_secret, :session_key, :uid ].each do |required|
        raise ArgumentError, "Missing required parameter: #{required}" if @settings[required].nil?
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

    def self.signature(callback_url, api_secret, params)
      path = URI.regexp(['http', 'https']).match(callback_url)[7]
      signed_parameters = params[:signed_keys].split(',')
      string_to_sign = [
              path,
              signed_parameters.sort.map { |key| "#{key}=#{params[key.to_sym]}" },
              api_secret
      ].flatten.join
      Digest::MD5::hexdigest(string_to_sign)
    end

    def build_params(options)
      options ||= {}
      {
        :api_key => @settings[:api_key],
        :session_key => session_key,
        :nonce => "#{Time.now.to_f}", 
        :format => 'json'
      }.merge(options)
    end
  end
end
