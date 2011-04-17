require 'addressable/uri'
require 'net/http'
require 'net/https'

module KontoAPI

  extend self

  VALIDITY_URL    = Addressable::URI.parse 'https://ask.kontoapi.de/for/validity.json'
  BANKNAME_URL    = Addressable::URI.parse 'https://ask.kontoapi.de/for/bankname.json'
  DEFAULT_TIMEOUT = 10

  @@api_key = nil
  def api_key=(key)
    @@api_key = key
  end
  def api_key
    @@api_key
  end

  @@timeout = nil
  def timeout=(new_timeout)
    @@timeout = new_timeout
  end
  def timeout
    @@timeout || DEFAULT_TIMEOUT
  end

  def valid?(account_number, bank_code)
    response = ask_for(:validity, { :ktn => account_number, :blz => bank_code })
    response[:answer].eql?('yes')
  end

  def bank_name(bank_code)
    response = ask_for(:bankname, { :blz => bank_code })
    response[:answer]
  end



 private

  def ask_for(what, options={})
    raise 'Please set your API Key first (KontoAPI::api_key = "<your_key>"). You can get one at https://www.kontoapi.de/' unless api_key
    url = const_get("#{what}_URL".upcase).dup
    options.merge!( :key => api_key )
    url.query_values = options
    body = get_url(url)
    NibblerJSON.parse(body)
  end

  def get_url(url)
    http = Net::HTTP.new(url.host, 443)
    http.use_ssl = true
    http.read_timeout = timeout
    # TODO include certs and enable SSL verification
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    response = http.get url.request_uri, 'User-agent' => 'Konto API Ruby Client'
    if Net::HTTPSuccess == response
      response.body
    else
      response.error!
    end
  end

end