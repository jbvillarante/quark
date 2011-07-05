require 'spec_helper'

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
      @api_domain = "some.api_domain.at.friendster.com"
      @params = {
              :api_key      => @api_key,
              :expires      => 0,
              :instance_id  => 1,
              :lang         => "en-US",
              :nonce        => 0,
              :session_key  => @session_key,
              :src          => "canvas",
              :user_id      => 2,
              :api_domain   => @api_domain
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
        @session.endpoint.should == "http://#{@api_domain}/v1"
      end
    end

    it "handles params with string keys" do
      @params["api_key"] = @params.delete(:api_key)
      session = Quark::Session.from_friendster(@callback_url, @api_secret, @params)
      session.instance_variable_get(:@settings)[:api_key].should == @api_key
    end

    it "defaults endpoint to http://api.friendster.com/v1 when no api_domain given" do
      @params.delete(:api_domain)
      @params.delete(:sig)
      @params.merge!(signed_keys: (@params.keys + [:signed_keys]).join(','))
      @params.merge!(sig: Quark::Util.signature(@callback_url, @api_secret, @params))
      session = Quark::Session.from_friendster(@callback_url, @api_secret, @params)
      session.endpoint.should == "http://api.friendster.com/v1"
    end

    it "creates a sandbox session when params includes sandbox: true" do
      @params["sandbox"] = true
      session = Quark::Session.from_friendster(@callback_url, @api_secret, @params)
      session.instance_variable_get(:@settings)[:sandbox].should be_true
    end

    context "when signature is invalid" do
      it "raises an error" do
        expect do
          Quark::Session.from_friendster(@callback_url, @api_secret, @params.merge(sig: "wrong"))
        end.to raise_error(Quark::InvalidSignatureError)
      end
    end
  end

  describe "#adjust_resource_for_sandbox" do
    context "when sandbox is true" do
      before do
        @session = Quark::Session.new(api_key: @api_key, api_secret: @api_secret, session_key: @session_key, uid: '43169473', sandbox: true)
      end

      it "replaces 'wallet/' with 'wallet-sandbox/' in resource" do
        data = {resource: 'wallet/commit'}
        @session.send(:adjust_resource_for_sandbox, data)
        data[:resource].should == 'wallet-sandbox/commit'
      end

      it "does not modify resource if resource is not 'wallet/'" do
        data = {resource: 'application/friends'}
        @session.send(:adjust_resource_for_sandbox, data)
        data[:resource].should == 'application/friends'
      end
    end

    context "when sandbox is false" do
      it "does not modify 'wallet/' in resource" do
        data = {resource: 'wallet/commit'}
        session = Quark::Session.new(api_key: @api_key, api_secret: @api_secret, session_key: @session_key, uid: '43169473', sandbox: false)
        session.send(:adjust_resource_for_sandbox, data)
        data[:resource].should == 'wallet/commit'
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

    describe 'passing options to Curl' do
      before do
        Quark::UnsignedRequest.should_receive(:get) do |endpoint, resource, options|
          options[:curl_options].should == { :any_curl_option => 'yes' }
        end
      end

      it "should pass the session Curl options when making network calls" do
        session = Quark::Session.new(@arguments.merge(:curl_options => { :any_curl_option => 'yes' }))
        session.get(:resource => 'anything')
      end
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
          "birthday"].each { |key| user_info.should have_key(key) }
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

    describe "#friends" do
      let(:session) { Quark::Session.new(@arguments) }
      let(:stub_response) { { :body => test_data('friends_response_valid.json') } }

      it "returns a list of friend IDs" do
        stub_request(:get, %r{/friends}).with(:params => { :format => 'json' }).to_return(stub_response)
        session.friends.should == JSON.parse(stub_response[:body])['friends']['uid']
      end

      it "accepts a user_id parameter (as Integer)" do
        stub_request(:get, %r{/friends/123}).with(:params => {:format => 'json'}).to_return(stub_response)
        session.friends(123)
      end

      it "accepts a user_id parameter (as String)" do
        stub_request(:get, %r{/friends/123}).with(:params => {:format => 'json'}).to_return(stub_response)
        session.friends('123')
      end
    end

    context "Wallet Convenience API calls" do
      describe "#wallet_balance" do
        context "non-sandbox mode" do
          it "retrieve the wallet balance of the user via /wallet/balance API method" do
            session = Quark::Session.new(@arguments)
            stub_response = {:body => test_data('wallet_balance_response_valid.json')}
            stub_request(:get, %r{/wallet/balance}).with(:params => {:format => 'json'}).to_return(stub_response)

            session.wallet_balance.should_not be_nil
            session.wallet_balance.should == 300
          end
        end

        context "sandbox mode" do
          it "retrieves the wallet balance of the user via /wallet-sandbox/balance API method" do
            @arguments.merge!(:sandbox => true)
            session = Quark::Session.new(@arguments)
            stub_response = {:body => test_data('wallet_sandbox_balance_response_valid.json')}
            stub_request(:get, %r{/wallet-sandbox/balance}).with(:params => {:format => 'json'}).to_return(stub_response)

            session.wallet_balance.should_not be_nil
            session.wallet_balance.should == 200000
          end
        end
      end

      describe "#wallet_payment" do
        before do
          @payment_params = {:name => "test product", :description => "test product description", :amt => 50}
        end

        context "non-sandbox mode" do
          it "returns the token and return_url via /wallet/payment API method" do
            session = Quark::Session.new(@arguments)
            stub_response = {:body => test_data('wallet_payment_response_valid.json')}
            stub_request(:post, %r{/wallet/payment}).with(:params => {:format => 'json'}.merge(@payment_params)).to_return(stub_response)

            wallet_payment = session.wallet_payment(@payment_params)
            wallet_payment['redirect_url'].should == "http://test.host/wallet/authenticate"
            wallet_payment['request_token'].should == "db281ea2c2344d19310b23b762778f"
          end
        end

        context "sandbox mode" do
          it "returns the token and return_url via /wallet-sandbox/payment API method" do
            @arguments.merge!(:sandbox => true)
            session = Quark::Session.new(@arguments)
            stub_response = {:body => test_data('wallet_sandbox_payment_response_valid.json')}
            stub_request(:post, %r{/wallet-sandbox/payment}).with(:params => {:format => 'json'}.merge(@payment_params)).to_return(stub_response)

            wallet_payment = session.wallet_payment(@payment_params)
            wallet_payment['redirect_url'].should == "http://test.host/wallet/authenticate"
            wallet_payment['request_token'].should == "bd281ea2c2344d19310b23b762772a"
          end
        end
      end

      describe "#wallet_commit" do
        before do
          @payment_token = "db281ea2c2344d19310b23b762778f"
        end

        context "non-sandbox mode" do
          it "returns the amt, transaction_id and timestamp via /wallet/commit API method" do
            session = Quark::Session.new(@arguments)
            stub_response = {:body => test_data('wallet_commit_response_valid.json')}
            stub_request(:post, %r{/wallet/commit}).with(:params => {:format => 'json'}.merge({:request_token => @payment_token})).to_return(stub_response)

            wallet_commit = session.wallet_commit(@payment_token)
            wallet_commit['amt'].should == "20"
            wallet_commit['transaction_id'].should == "14414efdc3c66457af4d"
            wallet_commit['timestamp'].should == "2011-02-21T11:13:25+08:00"
          end
        end

        context "sandbox mode" do
          it "returns the amt, transaction_id and timestamp via /wallet-sandbox/commit API method" do
            @arguments.merge!(:sandbox => true)
            session = Quark::Session.new(@arguments)
            stub_response = {:body => test_data('wallet_sandbox_commit_response_valid.json')}
            stub_request(:post, %r{/wallet-sandbox/commit}).with(:params => {:format => 'json'}.merge({:request_token => @payment_token})).to_return(stub_response)

            wallet_commit = session.wallet_commit(@payment_token)
            wallet_commit['amt'].should == "200"
            wallet_commit['transaction_id'].should == "9a414efdc3c66457af4d"
            wallet_commit['timestamp'].should == "2011-09-21T11:13:25+08:00"
          end
        end
      end

      describe "#wallet_create" do
        before do
          @uid = 100
          @coins = 2000
        end

        def do_request
          @session = Quark::Session.new(@arguments)
          wallet_params = {:coins => @coins, :wallet_key => 'wallet'}
          stub_response = {:body => test_data('wallet_create_response_valid.json')}
          stub_request(:post, %r{/wallet-sandbox/create/100}).with(:params => {:format => 'json'}.merge(wallet_params)).to_return(stub_response)
        end

        context "non-sandbox mode" do
          it "returns the uid, coins, and timestamp via /wallet-sandbox/create API method" do
            do_request
            wallet = @session.wallet_create(@uid, @coins)
            wallet['uid'].should == @uid.to_s
            wallet['coins'].should == @coins
            wallet['timestamp'].should == "2011-02-21T11:40:15+08:00"
          end
        end

        context "sandbox mode" do
          it "returns the uid, coins, and timestamp via /wallet-sandbox/create API method" do
            @arguments.merge!(:sandbox => true)
            do_request

            wallet = @session.wallet_create(@uid, @coins)
            wallet['uid'].should == @uid.to_s
            wallet['coins'].should == @coins
            wallet['timestamp'].should == "2011-02-21T11:40:15+08:00"
          end
        end
      end

      describe "#wallet_destroy" do
        before do
          @uid = 100
          @coins = 55
        end

        def do_request
          @session = Quark::Session.new(@arguments)
          stub_response = {:body => test_data('wallet_destroy_response_valid.json')}
          stub_request(:post, %r{/wallet-sandbox/destroy/100}).with(:params => {:format => 'json'}).to_return(stub_response)
        end

        context "non-sandbox mode" do
          it "returns the uid, coins, and timestamp via /wallet-sandbox/destroy API method" do
            do_request

            wallet = @session.wallet_destroy(@uid)
            wallet['uid'].should == @uid
            wallet['coins'].should == @coins
            wallet['timestamp'].should == "2011-02-21T12:25:19+08:00"
          end
        end

        context "sandbox mode" do
          it "returns the uid, coins, and timestamp via /wallet-sandbox/destroy API method" do
            @arguments.merge!(:sandbox => true)
            do_request

            wallet = @session.wallet_destroy(@uid)
            wallet['uid'].should == @uid
            wallet['coins'].should == @coins
            wallet['timestamp'].should == "2011-02-21T12:25:19+08:00"
          end
        end
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

      it "does not rename wallet resources when not in sandbox mode" do
        Quark::SignedRequest.should_receive(:get).with(anything, 'wallet/balance', anything, anything)
        session = Quark::Session.new(@arguments)
        session.get(:resource => 'wallet/balance', :params => {:format => 'json'})
      end

      it "renames wallet resources if in sandbox mode" do
        Quark::SignedRequest.should_receive(:get).with(anything, 'wallet-sandbox/balance', anything, anything)
        session = Quark::Session.new(@arguments.merge(sandbox: true))
        session.get(:resource => 'wallet/balance', :params => {:format => 'json'})
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

      it "does not rename wallet resources when not in sandbox mode" do
        Quark::SignedRequest.should_receive(:post).with(anything, 'wallet/commit', anything, anything)
        session = Quark::Session.new(@arguments)
        session.post(:resource => 'wallet/commit', :params => {:format => 'json'})
      end

      it "renames wallet resources if in sandbox mode" do
        Quark::SignedRequest.should_receive(:post).with(anything, 'wallet-sandbox/commit', anything, anything)
        session = Quark::Session.new(@arguments.merge(sandbox: true))
        session.post(:resource => 'wallet/commit', :params => {:format => 'json'})
      end

      describe '#notification' do

        let(:notification_params) { {:name=>"Sample Name", :label=>"Sample Label", :subject=>"Sample Subject", :type=> 2, :content => 'dummy data'} }
        before do
          @session = Quark::Session.new(api_key: @api_key, api_secret: @api_secret, session_key: @session_key, uid: '43169473')
        end

        specify 'should  call APIs directly and return the raw response' do
          stub_request(:post, %r{/notification}).with(:params => {:format => 'json'}).to_return(:body => test_data('post_notification_valid.json'))
          session = Quark::Session.new(@arguments)
          response = session.notification(%w[3448717 4534334 545434], 'test subject', 'test label', 'test content')
          response.should == ["3448717", "4534334", "545434"]
        end

        specify 'should accept a single number as a uid parameter' do
          stub_request(:post, %r{/notification}).with(:params => {:format => 'json'}).to_return(:body => "\[\"3448717\"]")
          session = Quark::Session.new(@arguments)
          response = session.notification(3448717, 'test subject', 'test label', 'test content')
          response.should == ["3448717"]
        end

        specify 'should return XML format when specified' do
          stub_request(:post, %r{/notification}).with(:params => {:format => 'xml'}).to_return(:headers => {'Content-Type' => "text/xml"}, :body => test_data('post_notification_valid.xml'))
          session = Quark::Session.new(@arguments)
          response = session.post(:resource => 'notification/3448717,4534334,545434', :params => notification_params)
          response.header_str.should include('text/xml')
          notification = Nokogiri::XML(response.body_str).css('uid')
          notification.map { |f| f.text}.should == ["3448717", "4534334", "545434"]
        end

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

      it "does not rename wallet resources when not in sandbox mode" do
        Quark::SignedRequest.should_receive(:put).with(anything, 'wallet/balance', anything, anything)
        session = Quark::Session.new(@arguments)
        session.put(:resource => 'wallet/balance', :params => {:format => 'json'})
      end

      it "renames wallet resources if in sandbox mode" do
        Quark::SignedRequest.should_receive(:put).with(anything, 'wallet-sandbox/balance', anything, anything)
        session = Quark::Session.new(@arguments.merge(sandbox: true))
        session.put(:resource => 'wallet/balance', :params => {:format => 'json'})
      end
    end
    
  end

  describe '#generate_wallet_authenticate_url' do
    before do
      @session = Quark::Session.new(api_key: @api_key, api_secret: @api_secret, session_key: @session_key, uid: '43169473')
    end

    it "generates a signed URL" do
      signed_url = @session.generate_wallet_authenticate_url("http://example.com/authenticate", "123")
      signed_url.should == "http://example.com/authenticate?request_token=123&api_key=#{@api_key}&signed_keys=api_key%2Crequest_token%2Csigned_keys&sig=173b63d810cf44a46da4cfc7d7ed73bd"
    end

    it "generates a signed URL" do
      signed_url = @session.generate_wallet_authenticate_url("http://example.com/authenticate", "123", "http://example.org/return_to_me")
      signed_url.should == "http://example.com/authenticate?request_token=123&api_key=#{@api_key}&return_url=http%3A%2F%2Fexample.org%2Freturn_to_me&signed_keys=api_key%2Crequest_token%2Creturn_url%2Csigned_keys&sig=11198d6a87d740d7e581ef897f206fd9"
    end
  end


end
