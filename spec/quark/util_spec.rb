require 'spec_helper'


describe "Quark::Util" do

  describe "#sign_auth_page" do
    signed_url =  Quark::Util.get_signed_url('12324', '5678', "http://www.google.com/path1/path2",{:params=>CGI.escape("session=12234567")})
    signed_url.should == "http://www.google.com/path1/path2?params=session%253D12234567&api_key=12324&sig=f2f480148f5c372ab6a3ced9288fe4a4"
  end

end