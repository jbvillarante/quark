require 'helper'

describe 'Quark::Session' do
  before :each do
    @api_key = '718fb34497589503915e85470d9d5511'
    @api_secret = 'b39c091ea8bb895345f652cc3217a1cf'
    @default_endpoint = 'http://api.friendster.com/v1'
    @session_key = 'placeholder'
  end

  describe ".from_friendster" do
    before do
      @callback_url = "http://example.com/callback"
      @endpoint = "http://some.endpoint.at.friendster.com/v1"
      @params = {
              :api_key      => @api_key,
              :expires      => 0,
              :instance_id  => 1,
              :lang         => "en-US",
              :nonce        => 0,
              :session_key  => @session_key,
              :src          => "canvas",
              :user_id      => 2,
              :endpoint     => @endpoint
      }
      @params.merge!(signed_keys: (@params.keys + [:signed_keys]).join(','))
      @params.merge!(sig: Quark::Util.signature(@callback_url, @api_secret, @params))
    end

    describe "creates a new session" do
      before do
        @session = Quark::Session.from_friendster(@callback_url, @api_secret, @params)
      end

      it "with api key" do
        @session.instance_variable_get(:@settings)[:api_key].should == @api_key
      end

      it "with session key" do
        @session.session_key.should == @session_key
      end

      it "with user id" do
        @session.uid.should == 2
      end

      it "with specified endpoint" do
        @session.endpoint.should == @endpoint
      end
    end

    context "when signature is invalid" do
      it "raises an error" do
        expect do
          Quark::Session.from_friendster(@callback_url, @api_secret, @params.merge(sig: "wrong"))
        end.to raise_error(Quark::InvalidSignatureError)
      end
    end
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
      stub_request(:get, %r{/albums}).with(:params => {:format => 'json'}).to_return(:body => test_data('albums_response_valid.json'))
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
    
    describe '/photos' do
      specify "should retrieve the list of photos in a specific album" do
        album_id = '709277604'
        stub_request(:get, %r{/photos}).with(:params => { :aid => album_id }).to_return(:body => test_data('photos_response_valid.json'))

        session = Quark::Session.new(@arguments)
        photos = session.photos(album_id)
        photos.should_not be_empty
        photos.each do |photo| 
          photo['owner'].should == session.uid
          photo['aid'].should == album_id
        end
      end
      
      specify "should retrieve all photos if no album is specified" do
        stub_request(:get, %r{/photos}).to_return(:body => test_data('photos_response_no_album_id.json'))

        session = Quark::Session.new(@arguments)
        photos = session.photos
        photos.should_not be_empty
        photos.each do |photo| 
          photo['owner'].should == session.uid
        end
      end

      specify "should return an empty array if the specified album is empty" do
        album_id = '709277604'
        stub_request(:get, %r{/photos}).with(:params => { :aid => album_id }).to_return(:body => test_data('photos_response_empty.json'))

        session = Quark::Session.new(@arguments)
        photos = session.photos(album_id)
        photos.should be_empty
      end
    end

    specify "should retrieve a photo" do
      stub_request(:get, %r{/photo\/\d*}).with(:params => {:format => 'json'}).to_return(:body => test_data('photo_response_valid.json'))
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
      stub_request(:get, %r{/primaryphoto}).with(:params => {:format => 'json'}).to_return(:body => test_data('primary_photo_response_valid.json'))
      session = Quark::Session.new(@arguments)
      primary_photo = session.primary_photo
      primary_photo.should_not be_empty
      primary_photo['owner'].should == session.uid
      %w{pid aid src src_small src_big link caption created is_grabbed}.each {|key|
        primary_photo.has_key?(key).should be_true
      }
    end

    describe "#user" do
      let(:session) { Quark::Session.new(@arguments) }
      let(:stub_response) { {:body => test_data('user_response_valid.json')} }

      specify "should retrieve his user information" do
        stub_request(:get, %r{/user}).with(:params => {:format => 'json'}).to_return(stub_response)
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

      it "should retrieve user info using a user_id (as Integer)" do
        stub_request(:get, %r{/user/123}).to_return(stub_response)
        session.user(123)
      end

      it "should retrieve user info using a user_id (as String)" do
        stub_request(:get, %r{/user/123}).to_return(stub_response)
        session.user('123')
      end

      it "should retrieve user info using an array of user ids" do
        stub_request(:get, %r{/user/123,888,777}).to_return(stub_response)
        session.user([123, '888', 777])
      end
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
    
    describe 'GET methods' do
      specify 'should  call APIs directly and return the raw response' do
        stub_request(:get, %r{/user}).with(:params => {:format => 'json'}).to_return(:body => test_data('user_response_valid.json'))
        session = Quark::Session.new(@arguments)
        response = session.get(:resource => 'user')
        response.should be_an_instance_of(Curl::Easy)
        [:body_str, :response_code].each {|method|
          response.should respond_to(method)
        }
      end

      specify 'should accept multiple params hash' do
        stub_request(:get, %r{/photos}).with(:params => {:format => 'json'}).to_return(:body => test_data('photos_response_valid.json'))
        session = Quark::Session.new(@arguments)
        album_id = '709277604'
        response = session.get(:resource => 'photos', :params => {:aid => album_id, :format => 'json'})
        photos = JSON.parse(response.body_str)['photo']
        photos.should_not be_empty
        photos.each do |photo|
          photo['owner'].should == session.uid
          photo['aid'].should == album_id
        end
      end

      specify 'should return XML format when specified' do
        stub_request(:get, %r{/user}).with(:params => {:format => 'xml'}).to_return(:headers => {'Content-Type' => "text/xml"}, :body => test_data('user_response_valid.xml'))
        session = Quark::Session.new(@arguments)
        response = session.get(:resource => 'user', :params => {:format => 'xml'})
        response.header_str.should include('text/xml')
        uid = Nokogiri::XML(response.body_str).css('uid').text
        uid.should == session.uid
      end

      specify 'should return JSON format when specified' do
        stub_request(:get, %r{/user}).with(:params => {:format => 'json'}).to_return(:headers => {'Content-Type' => "text/html"}, :body => test_data('user_response_valid.json'))
        session = Quark::Session.new(@arguments)
        response = session.get(:resource => 'user', :params => {:format => 'json'})
        response.headers.should_not include('text/xml')
        uid = JSON.parse(response.body_str)['user']['uid']
        uid.should == session.uid
      end    
    end
    
    describe 'POST methods' do
      specify 'should  call APIs directly and return the raw response' do
        stub_request(:post, %r{/shoutout}).with(:params => {:format => 'json'}).to_return(:body => test_data('post_shoutout_valid.json'))
        session = Quark::Session.new(@arguments)
        response = session.post(:resource => 'shoutout', :params => {:content => 'dummy data'})
        response.should be_an_instance_of(Curl::Easy)
        [:body_str, :response_code].each {|method|
          response.should respond_to(method)
        }
      end

      specify 'should return XML format when specified' do
        stub_request(:post, %r{/shoutout}).with(:params => {:format => 'xml'}).to_return(:headers => {'Content-Type' => "text/xml"}, :body => test_data('post_shoutout_valid.xml'))
        session = Quark::Session.new(@arguments)
        response = session.post(:resource => 'shoutout', :params => {:content => 'dummy data', :format => 'xml'})
        response.header_str.should include('text/xml')
        status = Nokogiri::XML(response.body_str).css('status').text
        status.should == 'updated'
      end

      specify 'should return JSON format when specified' do
        stub_request(:post, %r{/shoutout}).with(:params => {:format => 'json'}).to_return(:body => test_data('post_shoutout_valid.json'))
        session = Quark::Session.new(@arguments)
        response = session.post(:resource => 'shoutout', :params => {:content => 'dummy data', :format => 'json'})
        response.headers.should_not include('text/xml')
        status = JSON.parse(response.body_str)
        status.should == ['updated']
      end    
    end
    
    describe 'PUT methods' do
      specify 'should  call APIs directly and return the raw response' do
        stub_request(:put, %r{/photo/\d+/\d+}).with(:params => {:format => 'json'}).to_return(:body => test_data('put_photo_valid.json'))
        session = Quark::Session.new(@arguments)
        uid = session.uid
        pid = '12783185275'
        response = session.put(:resource => "photo/#{uid}/#{pid}", :params => {:caption => 'dummy caption'})
        response.should be_an_instance_of(Curl::Easy)
        [:body_str, :response_code].each {|method|
          response.should respond_to(method)
        }
      end

      specify 'should return XML format when specified' do
        stub_request(:put, %r{/photo/\d+/\d+}).with(:params => {:format => 'xml'}).to_return(:headers => { 'Content-Type' => "text/xml" }, :body => test_data('put_photo_valid.xml'))
        session = Quark::Session.new(@arguments)
        uid = session.uid
        pid = '12783185275'
        response = session.put(:resource => "photo/#{uid}/#{pid}", :params => {:caption => 'dummy caption', :format => 'xml'})
        response.header_str.should include('text/xml')
        status = Nokogiri::XML(response.body_str).css('status').text
        status.should == 'SUCCESS'
      end

      specify 'should return JSON format when specified' do
        stub_request(:put, %r{/photo/\d+/\d+}).with(:params => {:format => 'json'}).to_return(:body => test_data('put_photo_valid.json'))
        session = Quark::Session.new(@arguments)
        uid = session.uid
        pid = '12783185275'
        response = session.put(:resource => "photo/#{uid}/#{pid}", :params => {:caption => 'dummy caption', :format => 'json'})
        response.headers.should_not include('text/xml')
        status = JSON.parse(response.body_str)['status']
        status.should == 'SUCCESS'
      end    
    end
    
  end

end
