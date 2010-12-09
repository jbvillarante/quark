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
  
  describe 'User Photos' do
  
    before :each do 
      @arguments = {
        :api_key => @api_key,
        :api_secret => @api_secret,
        :session_key => 'Peni5ks8UkrpLayjuhpXy53EoiyCZ0zG-43169473',
        :uid => '43169473',
        :nonce => Time.now.to_f.to_s
      }
    end
    
    specify "should retrieve the list of his own albums" do
      stub_response = Typhoeus::Response.new(:code => 200, :headers => "", :body => test_data('albums_response_valid.json'))
      Typhoeus::Hydra.hydra.stub(:get, %r{/albums}).and_return(stub_response)
      session = Quark::Session.new(@arguments)
      albums = session.albums
      albums.should_not be_empty
      albums.each{|album| album['owner'].should == session.uid}
    end
    
    specify "should retrieve the list of photos in a specific album" do
      stub_response = Typhoeus::Response.new(:code => 200, :headers => "", :body => test_data('photos_response_valid.json'))
      Typhoeus::Hydra.hydra.stub(:get, %r{/photos}).and_return(stub_response)
      session = Quark::Session.new(@arguments)
      album_id = '709277604'
      photos = session.photos(album_id)
      photos.should_not be_empty
      photos.each do |photo| 
        photo['owner'].should == session.uid
        photo['aid'].should == album_id
      end
    end
    
    specify "should retrieve a photo" do
      stub_response = Typhoeus::Response.new(:code => 200, :headers => "", :body => test_data('photo_response_valid.json'))
      Typhoeus::Hydra.hydra.stub(:get, %r{/photo\/\d*}).and_return(stub_response)
      session = Quark::Session.new(@arguments)
      photo_id = '12864816732'
      photo = session.photo(photo_id)
      photo.should_not be_empty
      photo['owner'].should == session.uid
      photo['pid'].should == photo_id
    end
  end

end

