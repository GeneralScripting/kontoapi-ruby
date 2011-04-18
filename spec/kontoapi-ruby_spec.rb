require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "KontoAPI" do

  it "should raise if no api key was provided" do
    lambda { KontoAPI::valid?('1234567', '12312312') }.should raise_error(RuntimeError)
  end

  it "should raise if api key is invalid" do
    FakeWeb.register_uri(:get, %r|https://ask\.kontoapi\.de/for/validity.json?.*|, :body => '{"error":"unauthenticated"}', :status => ["401", "Unauthorized"])
    KontoAPI::api_key = 'abc123'
    lambda { KontoAPI::valid?('1234567', '12312312') }.should raise_error(Net::HTTPServerException)
  end

  context "checking validity" do

    it "should return false if account number or bank code are empty" do
      KontoAPI::valid?(nil, nil).should be_false
      KontoAPI::valid?('123', nil).should be_false
      KontoAPI::valid?(nil, '123').should be_false
      KontoAPI::valid?('', '').should be_false
      KontoAPI::valid?('123', '').should be_false
      KontoAPI::valid?('', '123').should be_false
    end

    it "should return true for successfull validity checks" do
      FakeWeb.register_uri(:get, %r|https://ask\.kontoapi\.de/for/validity.json?.*|, :body => '{"answer":"yes"}')
      KontoAPI::api_key = 'abc123'
      KontoAPI::valid?('correct_account_number', '12312312').should be_true
    end

    it "should return false for unsuccessfull validity checks" do
      FakeWeb.register_uri(:get, %r|https://ask\.kontoapi\.de/for/validity.json?.*|, :body => '{"answer":"no"}')
      KontoAPI::api_key = 'abc123'
      KontoAPI::valid?('incorrect_account_number', '12312312').should be_false
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
