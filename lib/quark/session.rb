module Quark
  class Session
    def initialize(params)
      @settings = {
        :endpoint => 'http://api.friendster.com/v1',
        :api_key => nil,
        :api_secret => nil,
        :session_key => nil
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
  end
end
