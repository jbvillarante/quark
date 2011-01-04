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
