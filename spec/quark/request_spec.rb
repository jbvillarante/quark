require 'helper'

describe 'Quark::UnsignedRequest' do
  before :each do
    @api_key = '718fb34497589503915e85470d9d5511'
    @api_secret = 'b39c091ea8bb895345f652cc3217a1cf'
    @default_endpoint = 'http://api.friendster.com/v1'
  end
  
  specify 'should not add a signature to its POST parameters' do
    resource = "token"
    stub_request(:post, "#{@default_endpoint}/#{resource}").with(:data => { :api_key => @api_key })
    Quark::UnsignedRequest.post(@default_endpoint, resource, :params => { :api_key => @api_key } )
  end

  specify 'should not add a signature to its GET parameters' do
    resource = "token"
    stub_request(:get, "#{@default_endpoint}/#{resource}").with(:query => { :api_key => @api_key })
    Quark::UnsignedRequest.get(@default_endpoint, resource, :params => { :api_key => @api_key } )
  end
  
  specify 'should not add a signature to its PUT parameters' do
    resource = "token"
    stub_request(:put, "#{@default_endpoint}/#{resource}").with(:body => "api_key=#{@api_key}")
    Quark::UnsignedRequest.put(@default_endpoint, resource, :params => { :api_key => @api_key } )
  end

  specify 'should throw an exception if response code is not 200' do
    resource = "token"
    stub_request(:get, %r{#{@default_endpoint}/#{resource}\?.*}).to_return(:status => 500)
    lambda {
      response = Quark::UnsignedRequest.get(@default_endpoint, resource, :params => { :api_key => @api_key } )
    }.should raise_error
  end

  specify 'should include the request object in its raised exceptions' do
    resource = "token"
    stub_request(:get, %r{#{@default_endpoint}/#{resource}\?.*}).to_return(:status => 500)
    lambda {
      response = Quark::UnsignedRequest.get(@default_endpoint, resource, :params => { :api_key => @api_key } )
    }.should raise_error
  end
end

describe 'Quark::SignedRequest' do
  before :each do
    @api_key = '718fb34497589503915e85470d9d5511'
    @api_secret = 'b39c091ea8bb895345f652cc3217a1cf'
    @default_endpoint = 'http://api.friendster.com/v1'
    @signature = 'fake-signature'
    Quark::SignedRequest.stub(:signature).and_return(@signature)
  end
  
  specify 'should add a signature to its POST parameters' do
    resource = "photos"
    stub_request(:post, "#{@default_endpoint}/#{resource}").with(:data => { :b => 1, :c => 2, :a => 0, :sig => @signature })
    Quark::SignedRequest.post(@default_endpoint, resource, @api_secret, :params => { :b => 1, :c => 2, :a => 0 })
  end

  specify 'should add a signature to its GET parameters' do
    resource = "token"
    stub_request(:get, "#{@default_endpoint}/#{resource}").with(:query => { :api_key => @api_key, :sig => @signature })
    Quark::SignedRequest.get(@default_endpoint, resource, @api_secret, :params => { :api_key => @api_key } )
  end
  
  specify 'should add a signature to its PUT parameters' do
    resource = "token"
    stub_request(:put, "#{@default_endpoint}/#{resource}").with(:params => "api_key=#{@api_key}&sig=#{@signature}")
    Quark::SignedRequest.put(@default_endpoint, resource, @api_secret, :params => { :api_key => @api_key } )
  end

  specify 'should throw an exception if response code is not 200' do
    resource = "token"
    stub_request(:get, "#{@default_endpoint}/#{resource}").to_return(:status => 500)
    lambda {
      Quark::SignedRequest.get(@default_endpoint, resource, @api_secret, params => { :api_key => @api_key } )
    }.should raise_error
  end
end

describe 'Quark::Exception' do
  context "when JSON is returned" do
    specify 'should return the error message when outputting the exception' do
      stub_request(:any, 'api.friendster.com').to_return(:status => 500, :headers => { 'Content-Type' =>  'application/json' }, :body => { :error_code => '100', :error_msg => 'Error Message' }.to_json)
      e = Quark::Exception.new(Curl::Easy.http_get('api.friendster.com'))
      e.message.should == '100: Error Message'
      e.error_code.should == '100'
      e.error_message.should == 'Error Message'
    end
  end

  context "when XML is returned" do
    context "when message is in <error_msg>" do
      specify 'should return the error message when outputting the exception' do
        stub_request(:any, 'api.friendster.com').to_return(:status => 500,
          :headers => { 'Content-Type' =>  'application/xml' },
          :body => '<?xml version="1.0" encoding="UTF-8"?>
            <error_response>
              <error_code>100</error_code>
              <error_msg>Error Message</error_msg>
            </error_response>'
        )
        e = Quark::Exception.new(Curl::Easy.http_get('api.friendster.com'))
        e.message.should == '100: Error Message'
        e.error_code.should == '100'
        e.error_message.should == 'Error Message'
      end
    end

    context "when message is in <error_message>" do
      specify 'should return the error message when outputting the exception' do
        stub_request(:any, 'api.friendster.com').to_return(:status => 500,
          :headers => { 'Content-Type' =>  'application/xml' },
          :body => '<?xml version="1.0" encoding="UTF-8"?>
            <error_response>
              <error_code>100</error_code>
              <error_message>Error Message</error_message>
            </error_response>'
          )

        e = Quark::Exception.new(Curl::Easy.http_get('api.friendster.com'))
        e.message.should == '100: Error Message'
        e.error_code.should == '100'
        e.error_message.should == 'Error Message'
      end
    end
  end

  context "when the error response not JSON or XML" do
    specify 'should return the error message when outputting the exception' do
      stub_request(:any, 'api.friendster.com').to_return(:status => 500, :headers => { 'Content-Type' => 'application/xml'}, :body => 'whatever')
      e = Quark::Exception.new(Curl::Easy.perform('api.friendster.com'))
      e.message.should == '0xdeadbeef: Could not read the error response from the server'
      e.error_code.should == '0xdeadbeef'
      e.error_message.should == 'Could not read the error response from the server'
    end
  end
end
