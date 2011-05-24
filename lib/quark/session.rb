require 'json'

module Quark
  class Session
    def self.from_friendster(callback_url, secret_key, params)
      # params.symbolize_keys!
      params.keys.each do |key|
        params[(key.to_sym rescue key) || key] = params.delete(key)
      end

      raise Quark::InvalidSignatureError if params[:sig] != Quark::Util.signature(callback_url, secret_key, params)
      args = { api_secret: secret_key, api_key: params[:api_key], session_key: params[:session_key], uid: params[:user_id] }
      args.merge!(endpoint: "https://#{params[:api_domain]}/v1") if params.has_key?(:api_domain)
      args.merge!(sandbox: (params[:sandbox] != "false" && !!params[:sandbox])) if params.has_key?(:sandbox)
      Session.new(args)
    end

    def initialize(params)
      @settings = {
        :endpoint => 'http://api.friendster.com/v1',
        :sandbox => false
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

    def friends(user_id = nil)
      resource = user_id.nil? ? "friends" : "friends/#{user_id}"
      response = get(:resource => resource)
      JSON.parse(response.body_str)['friends']['uid']
    end

    def wallet_balance
      response = get(:resource => "wallet/balance")
      JSON.parse(response.body_str)['coins']
    end

    def wallet_payment(data)
      response = post(:resource => "wallet/payment", :params => data)
      JSON.parse(response.body_str)
    end

    def wallet_commit(request_token)
      response = post(:resource => "wallet/commit", :params => {:request_token => request_token})
      JSON.parse(response.body_str)
    end

    def wallet_destroy(uid)
      response = post(:resource => "wallet-sandbox/destroy/#{uid}")
      JSON.parse(response.body_str)
    end

    def wallet_create(uid, coins)
      response = post(:resource => "wallet-sandbox/create/#{uid}", :params => {:coins => coins, :wallet_key => "wallet"})
      JSON.parse(response.body_str)
    end

    def notification(uids, subject, label, content, type =2)
      response = post(:resource => "notification/#{uids.join(',')}", :params => {:subject => subject, :label => label, :content => content, :type => type})
      JSON.parse(response.body_str)
    end

    def generate_wallet_authenticate_url(redirect_url, token, return_url=nil)
      params = { request_token: token, api_key: @settings[:api_key] }
      params.merge!(return_url: return_url) unless return_url.nil?
      params[:signed_keys] = (params.keys.sort + [:signed_keys]).join(',')
      sig = Quark::Util.signature(redirect_url, @settings[:api_secret], params)
      "#{redirect_url}?#{params.map { |k, v| "#{k}=#{URI.encode_www_form_component(v)}" }.join('&')}&sig=#{sig}"
    end

    def get(data)
      adjust_resource_for_sandbox(data)
      Quark::SignedRequest.get(endpoint, data[:resource], @settings[:api_secret], build_request_options(data[:params]))
    end
    
    def post(data)
      adjust_resource_for_sandbox(data)
      Quark::SignedRequest.post(endpoint, data[:resource], @settings[:api_secret], build_request_options(data[:params]))
    end
    
    def put(data)
      adjust_resource_for_sandbox(data)
      Quark::SignedRequest.put(endpoint, data[:resource], @settings[:api_secret], build_request_options(data[:params]))
    end

    private

    def adjust_resource_for_sandbox(data)
      data[:resource].gsub!("wallet/", "wallet-sandbox/") if @settings[:sandbox]
    end

    def build_request_options(data)
      options = {}
      data ||= {}

      options[:params] = {
        :api_key => @settings[:api_key],
        :session_key => session_key,
        :nonce => "#{Time.now.to_f}", 
        :format => 'json'
      }.merge(data)

      options[:curl_options] = @settings[:curl_options] if @settings[:curl_options]
      options
    end
  end
end
