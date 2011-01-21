require 'helper'

describe 'Quark::UnsignedRequest' do
  before :each do
    @api_key = '718fb34497589503915e85470d9d5511'
    @api_secret = 'b39c091ea8bb895345f652cc3217a1cf'
    @default_endpoint = 'http://api.friendster.com/v1'
  end
  
  specify 'should not add a signature to its POST parameters' do
    resource = "token"
    Typhoeus::Hydra.hydra.stub(:post, "#{@default_endpoint}/#{resource}").and_return(Typhoeus::Response.new(:code => 200))
    response = Quark::UnsignedRequest.post(@default_endpoint, resource, :params => { :api_key => @api_key } )
    response.mock.should be_true
    response.request.params.should_not include :sig
  end

  specify 'should not add a signature to its GET parameters' do
    resource = "token"
    Typhoeus::Hydra.hydra.stub(:get, %r{#{@default_endpoint}/#{resource}\?.*}).and_return(Typhoeus::Response.new(:code => 200))
    response = Quark::UnsignedRequest.get(@default_endpoint, resource, :params => { :api_key => @api_key } )
    response.mock.should be_true
    response.request.params.should_not include :sig
  end

  specify 'should throw an exception if response code is not 200' do
    resource = "token"
    Typhoeus::Hydra.hydra.stub(:get, %r{#{@default_endpoint}/#{resource}\?.*}).and_return(Typhoeus::Response.new(:code => 500))
    lambda {
      response = Quark::UnsignedRequest.get(@default_endpoint, resource, :params => { :api_key => @api_key } )
    }.should raise_error
  end

  specify 'should include the request object in its raised exceptions' do
    resource = "token"
    response = Typhoeus::Response.new(:code => 500)
    Typhoeus::Hydra.hydra.stub(:get, %r{#{@default_endpoint}/#{resource}\?.*}).and_return(response)
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
  end
  
  specify 'should add a signature to its POST parameters' do
    resource = "photos"
    Typhoeus::Hydra.hydra.stub(:post, "#{@default_endpoint}/#{resource}").and_return(Typhoeus::Response.new(:code => 200))
    response = Quark::SignedRequest.post(@default_endpoint, resource, @api_secret, :params => { :b => 1, :c => 2, :a => 0 } )
    response.mock.should be_true
    response.request.params.should include :sig
    response.request.params[:sig].should == Digest::MD5.hexdigest([ '/v1/photos', 'a=0', 'b=1', 'c=2', @api_secret ].join)
  end

  specify 'should add a signature to its GET parameters' do
    resource = "token"
    Typhoeus::Hydra.hydra.stub(:get, %r{#{@default_endpoint}/#{resource}\?.*}).and_return(Typhoeus::Response.new(:code => 200))
    response = Quark::SignedRequest.get(@default_endpoint, resource, @api_secret, :params => { :api_key => @api_key } )
    response.mock.should be_true
    response.request.params.should include :sig
    response.request.params[:sig].should == Digest::MD5.hexdigest([ "/v1/#{resource}", "api_key=#{@api_key}", @api_secret ].join)
  end

  specify 'should throw an exception if response code is not 200' do
    resource = "token"
    Typhoeus::Hydra.hydra.stub(:get, %r{#{@default_endpoint}/#{resource}\?.*}).and_return(Typhoeus::Response.new(:code => 500))
    lambda {
      response = Quark::SignedRequest.get(@default_endpoint, resource, @api_secret, params => { :api_key => @api_key } )
    }.should raise_error
  end
end

describe 'Quark::Exception' do
  context "when JSON is returned" do
    specify 'should return the error message when outputting the exception' do
      error_response = Typhoeus::Response.new(:code => 500, :headers => 'Content-Type: application/json', :body => { :error_code => '100', :error_msg => 'Error Message' }.to_json)

      e = Quark::Exception.new(error_response)
      e.message.should == '100: Error Message'
    end
  end

  context "when XML is returned" do
    context "when message is in <error_msg>" do
      specify 'should return the error message when outputting the exception' do
        error_response = Typhoeus::Response.new(:code => 500, :headers => 'Content-Type: application/xml', :body => '<?xml version="1.0" encoding="UTF-8"?>
        <error_response>
          <error_code>100</error_code>
          <error_msg>Error Message</error_msg>
        </error_response>'
        )

        e = Quark::Exception.new(error_response)
        e.message.should == '100: Error Message'
      end
    end

    context "when message is in <error_message>" do
      specify 'should return the error message when outputting the exception' do
        error_response = Typhoeus::Response.new(:code => 500, :headers => 'Content-Type: application/xml', :body => '<?xml version="1.0" encoding="UTF-8"?>
          <error_response>
            <error_code>100</error_code>
            <error_message>Error Message</error_message>
          </error_response>'
        )

        e = Quark::Exception.new(error_response)
        e.message.should == '100: Error Message'
      end
    end
  end

  context "when the error response not JSON or XML" do
    specify 'should return the error message when outputting the exception' do
      error_response = Typhoeus::Response.new(:code => 500, :headers => 'Content-Type: text/html', :body => 'whatever')

      e = Quark::Exception.new(error_response)
      e.message.should == '0xdeadbeef: Could not read the error response from the server'
    end
  end
end