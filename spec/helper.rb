require 'bundler'

begin
  Bundler.require(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'quark'
require 'webmock/rspec'

RSpec.configure do |config|
  config.before(:each) {}
end

def test_data(file_name)
  path = File.join(File.dirname(__FILE__), 'data', file_name)
  File.open(path, 'r') { |handle| handle.read }
end

