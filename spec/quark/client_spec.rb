require 'spec_helper'

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
    stub_request(:post, %r{/token}).with(:data => { :format => 'json' }).to_return(:body => test_data('token_response_valid.json'))

    client = Quark::Client.new(:api_key => @api_key, :api_secret => @api_secret)
    client.get_token.should == '840d82214118f22.88053767'
  end

  specify 'can log in with a user email and password using a trusted API key' do
    stub_request(:post, %r{/token}).with(:data => { :format => 'json' }).to_return(:body => test_data('token_response_valid.json'))
    stub_request(:post, %r{/login}).with(:data => { :format => 'json' }).to_return(:body => test_data('login_response_valid.json'))
    
    uid = '43169473'
    email = 'fake@gmail.com'
    password = 'fake'
    
    client = Quark::Client.new(:api_key => @api_key, :api_secret => @api_secret)
    session = client.login(email, password)
    session.session_key.should == 'Peni5ks8UkrpLayjuhpXy53EoiyCZ0zG-43169473'
    session.uid.should == uid
  end

  describe '#create_session' do
    let(:session_key) { 'foo' }
    let(:uid) { 18236912940 }

    it 'create a session with a session key and UID' do
      client = Quark::Client.new(:api_key => @api_key, :api_secret => @api_secret)
      session = client.create_session(:session_key => session_key, :uid => uid)
      session.session_key.should == session_key
      session.uid.should == uid
    end

    specify 'passes curl_options to the session' do
      client = Quark::Client.new(:api_key => @api_key, :api_secret => @api_secret, :curl_options => { :any_curl_option => true })
      session = client.create_session(:session_key => session_key, :uid => uid)
      session.instance_variable_get(:@settings)[:curl_options].should == { :any_curl_option => true }
    end
  end

  describe 'create_session_from_token' do
    specify 'can obtain a session key and UID from an authenticated auth_token' do
      auth_token = 'sadfasdfasdrqewpir'
      stub_request(:post, %r{/session}).with(:data => { :auth_token => auth_token, :format => 'json' }).to_return(:body => test_data('session_response_valid.json'))
      client = Quark::Client.new(:api_key => @api_key, :api_secret => @api_secret)
      session = client.create_session_from_token(auth_token)
      session.session_key.should == 'Peni5ks8UkrpLayjuhpXy53EoiyCZ0zG-43169473'
      session.uid.should == '43169473'
    end

    specify 'should raise a helpful error if auth_token parameter is nil' do
    end
  end
  
end
