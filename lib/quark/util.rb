module Quark
  class Util
    def self.signature(url, secret_key, options)
      path = URI.regexp(['http', 'https']).match(url)[7]
      signed_parameters = if (options[:signed_keys])
         options[:signed_keys].split(',')
      else
          options.keys
      end
      string_to_sign = [
              path,
              signed_parameters.sort.map { |key| "#{key}=#{options[key.to_sym]}" },
              secret_key
      ].flatten.join
      Digest::MD5::hexdigest(string_to_sign)
    end

    def self.query_string(params)
      params.map {|k,v| "#{k}=#{CGI.escape(v)}"}.join("&")
    end

    def self.get_signed_url(api_key, secret_key, host_path, params={})
         params[:api_key] = api_key
         sig = signature(host_path, secret_key, params)
         "#{host_path}?#{query_string(params)}&sig=#{sig}"
    end

  end

end