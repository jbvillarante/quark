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
  
  describe 'User Convenience API Calls' do
  
    before :each do 
      @arguments = {
        :api_key => @api_key,
        :api_secret => @api_secret,
        :session_key => 'Peni5ks8UkrpLayjuhpXy53EoiyCZ0zG-43169473',
        :uid => '43169473'
      }
    end
    
    specify "should retrieve the list of his own albums" do
      stub_response = Typhoeus::Response.new(:code => 200, :headers => "", :body => test_data('albums_response_valid.json'))
      Typhoeus::Hydra.hydra.stub(:get, %r{/albums}).and_return(stub_response)
      session = Quark::Session.new(@arguments)
      albums = session.albums
      albums.should_not be_empty
      albums.each do |album| 
        album['owner'].should == session.uid
        %w{aid cover_pid owner name created modified description isprivate link size}.each {|key|
          album.has_key?(key).should be_true
        }
      end
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
      %w{aid src src_small src_big link caption created is_grabbed}.each {|key|
        photo.has_key?(key).should be_true
      }
    end
    
    specify "should retrieve primary photo" do
      stub_response = Typhoeus::Response.new(:code => 200, :headers => "", :body => test_data('primary_photo_response_valid.json'))
      Typhoeus::Hydra.hydra.stub(:get, %r{/primaryphoto}).and_return(stub_response)
      session = Quark::Session.new(@arguments)
      primary_photo = session.primary_photo
      primary_photo.should_not be_empty
      primary_photo['owner'].should == session.uid
      %w{pid aid src src_small src_big link caption created is_grabbed}.each {|key|
        primary_photo.has_key?(key).should be_true
      }
    end
    
    specify "should retrieve his user information" do
      stub_response = Typhoeus::Response.new(:code => 200, :headers => "", :body => test_data('user_response_valid.json'))
      Typhoeus::Hydra.hydra.stub(:get, %r{/user}).and_return(stub_response)
      session = Quark::Session.new(@arguments)
      user_info = session.user
      user_info.should_not be_empty
      user_info['uid'].should == session.uid
      [ "first_name",
        "last_name",
        "url",
        "primary_photo_url",
        "location",
        "hometown", 
        "user_type", 
        "fan_profile_type",
        "fan_profile_category",
        "relationship_status",
        "gender",
        "member_since",
        "interested_in",
        "occupation",
        "companies",
        "hobbies_and_interests",
        "affiliations",
        "college_list",
        "school_list",
        "school_other",
        "favorites",
        "about_me",
        "want_to_meet", 
        "birthday"].each {|key| user_info.has_key?(key).should be_true }
    end
  end
  
  describe 'User Direct API Calls' do
    
    before :each do
      @arguments = {
        :api_key => @api_key,
        :api_secret => @api_secret,
        :session_key => 'Peni5ks8UkrpLayjuhpXy53EoiyCZ0zG-43169473',
        :uid => '43169473'
      }    
    end

    specify 'should  call APIs directly and return the raw response' do
      stub_response = Typhoeus::Response.new(:code => 200, :headers => "", :body => test_data('user_response_valid.json'))
      Typhoeus::Hydra.hydra.stub(:get, %r{/user}).and_return(stub_response)
      session = Quark::Session.new(@arguments)
      response = session.get(:resource => 'user')
      puts response
      response.should be_an_instance_of(Typhoeus::Response)
      [:body, :code, :status_message, :request].each {|method|
        response.should respond_to(method)
      }
    end

    specify 'should accept an multiple params hash' do
      stub_response = Typhoeus::Response.new(:code => 200, :headers => "", :body => test_data('photos_response_valid.json'))
      Typhoeus::Hydra.hydra.stub(:get, %r{/photos}).and_return(stub_response)
      session = Quark::Session.new(@arguments)
      album_id = '709277604'
      response = session.get(:resource => 'photos', :params => {:aid => album_id, :format => 'json'})
      photos = JSON.parse(response.body)['photo']
      photos.should_not be_empty
      photos.each do |photo|
        photo['owner'].should == session.uid
        photo['aid'].should == album_id
      end
    end

    specify 'should return XML format when specified' do
      stub_response = Typhoeus::Response.new(:code => 200, :headers => "Content-Type: text/xml", :body => test_data('user_response_valid.xml'))
      Typhoeus::Hydra.hydra.stub(:get, %r{/user}).and_return(stub_response)
      session = Quark::Session.new(@arguments)
      response = session.get(:resource => 'user', :params => {:format => 'xml'})
      response.headers.should include('text/xml')
      uid = Nokogiri::XML(response.body).css('uid').text
      uid.should == session.uid
    end

    specify 'should return JSON format when specified' do
      stub_response = Typhoeus::Response.new(:code => 200, :headers => "Content-Type: text/html", :body => test_data('user_response_valid.json'))
      Typhoeus::Hydra.hydra.stub(:get, %r{/user}).and_return(stub_response)
      session = Quark::Session.new(@arguments)
      response = session.get(:resource => 'user', :params => {:format => 'json'})
      response.headers.should_not include('text/xml')
      uid = JSON.parse(response.body)['user']['uid']
      uid.should == session.uid
    end
  end

end