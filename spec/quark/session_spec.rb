require 'helper'

describe 'Quark' do
  before :each do
    @api_key = '718fb34497589503915e85470d9d5511'
    @api_secret = 'b39c091ea8bb895345f652cc3217a1cf'
    @default_endpoint = 'http://api.friendster.com/v1'

  end

  describe 'session creation' do
    before :each do
      stub_data = <<-XML
      <?xml version="1.0" encoding="UTF-8" ?><token_response xmlns="http://api.friendster.com/v1/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://api.friendster.com/v1/ http://api.friendster.com/v1/friendster.xsd" ><auth_token>74cef776c6338d8.40566214</auth_token></token_response>
      XML
      stub_response = Typhoeus::Response.new(:code => 200, :headers => "", :body => stub_data)
      Typhoeus::Hydra.hydra.stub(:post, "#{@default_endpoint}/token").and_return(stub_response)
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
      session.endpoint.should == @default_endpoint
    end

    specify 'should succeed given a valid API key' do
      lambda {
        session = Quark::Session.new(:api_key => @api_key, :api_secret => '')
        session.session_key.should_not be_nil
      }.should_not raise_error
    end
  
    specify 'should raise an error given an invalid API key' do
      lambda { Quark::Session.new(:api_key => '', :api_secret => @api_secret) }.should raise_error
    end
  end

end
