require 'helper'

describe 'Quark::Session' do
  before :each do
    @api_key = '718fb34497589503915e85470d9d5511'
    @api_secret = 'b39c091ea8bb895345f652cc3217a1cf'
    @default_endpoint = 'http://api.friendster.com/v1'
    @session_key = 'placeholder'
  end

  describe 'parameter validation' do
    before :each do 
      @arguments = {
        :api_key => @api_key,
        :api_secret => @api_secret,
        :session_key => 'fake_session_key',
        :uid => 'fake_uid'
      }
    end

    specify 'should require a session key' do
      lambda {
        @arguments.delete(:session_key)
        Quark::Session.new(@arguments)
      }.should raise_error
    end

    specify 'should require an associated user ID' do
      lambda {
        @arguments.delete(:uid)
        Quark::Session.new(@arguments)
      }.should raise_error
    end

    specify 'should require an API key' do
      lambda {
        @arguments.delete(:api_key)
        Quark::Session.new(@arguments)
      }.should raise_error
    end

    specify 'should require an API secret' do
      lambda {
        @arguments.delete(:api_secret)
        Quark::Session.new(@arguments)
      }.should raise_error
    end

    specify 'should allow setting the API endpoint' do
      endpoint = 'http://localhost/v1'
      @arguments.merge!(:endpoint => endpoint)
      client = Quark::Session.new(@arguments)
      client.endpoint.should == endpoint
    end

    specify "should default to Friendster's v1 API endpoint" do
      client = Quark::Session.new(@arguments)
      client.endpoint.should == @default_endpoint
    end
  end

end

