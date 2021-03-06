require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "KontoAPI" do

  it "should raise if no api key was provided" do
    lambda { KontoAPI::valid?( :ktn => '1234567', :blz => '12312312' ) }.should raise_error(RuntimeError)
  end

  it "should raise if api key is invalid" do
    FakeWeb.register_uri(:get, %r|https://ask\.kontoapi\.de/for/validity.json?.*|, :body => '{"error":"unauthenticated"}', :status => ["401", "Unauthorized"])
    KontoAPI::api_key = 'abc123'
    lambda { KontoAPI::valid?( :ktn => '1234567', :blz => '12312312' ) }.should raise_error(Net::HTTPServerException)
  end

  context "checking validity" do

    it "should return false if account number or bank code are empty" do
      KontoAPI::valid?( :ktn => nil, :blz => nil ).should be false
      KontoAPI::valid?( :ktn => '123', :blz => nil ).should be false
      KontoAPI::valid?( :ktn => nil, :blz => '123' ).should be false
      KontoAPI::valid?( :ktn => '', :blz => '' ).should be false
      KontoAPI::valid?( :ktn => '123', :blz => '' ).should be false
      KontoAPI::valid?( :ktn => '', :blz => '123' ).should be false
    end

    it "should return true for successfull validity checks" do
      FakeWeb.register_uri(:get, %r|https://ask\.kontoapi\.de/for/validity.json?.*|, :body => '{"answer":"yes"}')
      KontoAPI::api_key = 'abc123'
      KontoAPI::valid?( :ktn => 'correct_account_number', :blz => '12312312' ).should be true
    end

    it "should return false for unsuccessfull validity checks" do
      FakeWeb.register_uri(:get, %r|https://ask\.kontoapi\.de/for/validity.json?.*|, :body => '{"answer":"no"}')
      KontoAPI::api_key = 'abc123'
      KontoAPI::valid?( :ktn => 'incorrect_account_number', :blz => '12312312' ).should be false
    end

  end

  context "getting bank names" do

    it "should return nil if no bank code was provided" do
      KontoAPI::bank_name(nil).should be_nil
      KontoAPI::bank_name('').should be_nil
    end

    it "should return nil if no bank was found" do
      FakeWeb.register_uri(:get, %r|https://ask\.kontoapi\.de/for/bankname.json?.*|, :body => '{"answer":""}')
      KontoAPI::api_key = 'abc123'
      KontoAPI::bank_name('12312312').should be_nil
    end

    it "should return Postbank for bank code 10010010" do
      FakeWeb.register_uri(:get, %r|https://ask\.kontoapi\.de/for/bankname.json?.*|, :body => '{"answer":"Postbank"}')
      KontoAPI::api_key = 'abc123'
      KontoAPI::bank_name('10010010').should == "Postbank"
    end

  end

end
