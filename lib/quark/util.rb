module Quark
  class Util
    def self.signature(url, secret_key, options)
      path = URI.regexp(['http', 'https']).match(url)[7]
      signed_parameters = options[:signed_keys].split(',')
      string_to_sign = [
              path,
              signed_parameters.sort.map { |key| "#{key}=#{options[key.to_sym]}" },
              secret_key
      ].flatten.join
      Digest::MD5::hexdigest(string_to_sign)
    end
  end
end