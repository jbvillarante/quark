require 'helper'

describe 'Quark' do
  before :each do
    @api_key = '718fb34497589503915e85470d9d5511'
    @api_secret = 'b39c091ea8bb895345f652cc3217a1cf'
  end

  specify 'should create a new session from a valid API key and secret' do
    lambda { Quark::Session.new(:api_key => @api_key, :api_secret => @api_secret) }.should_not raise_error
  end
  
  specify 'should require setting the API key' do
    lambda { Quark::Session.new(:api_secret => @api_secret) }.should raise_error
  end

  specify 'should require setting the API secret' do
    lambda { Quark::Session.new(:api_key => @api_key) }.should raise_error
  end

  specify 'should allow setting the API endpoint' do
    endpoint = 'http://localhost/v1'
    session = Quark::Session.new(:api_key => @api_key, :api_secret => @api_secret, :endpoint => endpoint)
    session.endpoint.should == endpoint
  end

  specify "should default to Friendster's v1 API endpoint" do
    session = Quark::Session.new(:api_key => @api_key, :api_secret => @api_secret)
    session.endpoint.should == 'http://api.friendster.com/v1'
  end

  specify 'should raise an error when trying to create a session from an invalid API key' do
    lambda { Quark::Session.new(:api_key => '', :api_secret => @api_secret) }.should raise_error
  end
end
