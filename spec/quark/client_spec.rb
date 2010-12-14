require 'helper'

describe 'Quark::Client' do
  before :each do
    @api_key = '718fb34497589503915e85470d9d5511'
    @api_secret = 'b39c091ea8bb895345f652cc3217a1cf'
    @default_endpoint = 'http://api.friendster.com/v1'
  end

  specify 'should require setting the API key' do
    lambda { Quark::Client.new(:api_secret => @api_secret) }.should raise_error
  end

  specify 'should require setting the API secret' do
    lambda { Quark::Client.new(:api_key => @api_key) }.should raise_error
  end

  specify 'should allow setting the API endpoint' do
    endpoint = 'http://localhost/v1'
    client = Quark::Client.new(:api_key => @api_key, :api_secret => @api_secret, :endpoint => endpoint)
    client.endpoint.should == endpoint
  end

  specify "should default to Friendster's v1 API endpoint" do
    client = Quark::Client.new(:api_key => @api_key, :api_secret => @api_secret)
    client.endpoint.should == @default_endpoint
  end

  specify 'should be able to obtain an auth_token' do
    stub_response = Typhoeus::Response.new(:code => 200, :headers => "", :body => test_data('token_response_valid.xml'))
    Typhoeus::Hydra.hydra.stub(:post, %r{/token}).and_return(stub_response)

    client = Quark::Client.new(:api_key => @api_key, :api_secret => @api_secret)
    client.get_token.should == '74cef776c6338d8.40566214'
  end

  specify 'can log in with a user email and password using a trusted API key' do
    stub_response = Typhoeus::Response.new(:code => 200, :headers => "", :body => test_data('login_response_valid.xml'))
    Typhoeus::Hydra.hydra.stub(:post, %r{/login}).and_return(stub_response)
    
    uid = '43169473'
    email = 'fake@gmail.com'
    password = 'fake'
    
    client = Quark::Client.new(:api_key => @api_key, :api_secret => @api_secret)
    session = client.login(email, password)
    session.session_key.should == 'Peni5ks8UkrpLayjuhpXy53EoiyCZ0zG-43169473'
    session.uid.should == uid
  end

  specify 'can accept a session key and UID directly' do
    session_key = 'foo'
    uid = 18236912940
    client = Quark::Client.new(:api_key => @api_key, :api_secret => @api_secret)
    session = client.create_session(:session_key => session_key, :uid => uid)
    session.session_key.should == session_key
    session.uid.should == uid
  end

  specify 'can obtain a session key and UID from an authenticated auth_token' do
    stub_response = Typhoeus::Response.new(:code => 200, :headers => "", :body => test_data('session_response_valid.xml'))
    Typhoeus::Hydra.hydra.stub(:post, %r{/session}).and_return(stub_response)
    client = Quark::Client.new(:api_key => @api_key, :api_secret => @api_secret)
    session = client.create_session_from_token(@auth_token)
    session.session_key.should == 'Peni5ks8UkrpLayjuhpXy53EoiyCZ0zG-43169473'
    session.uid.should == '43169473'
  end
  
end
