require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'rspec'
RSpec.configure do |config|
  config.before(:each) {
    Typhoeus::Hydra.hydra.clear_stubs
  }
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'quark'

def test_data(file_name)
  path = File.join(File.dirname(__FILE__), 'data', file_name)
  File.open(path, 'r') { |handle| handle.read }
end

require 'nokogiri'