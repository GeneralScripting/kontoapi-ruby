require 'addressable/uri'
require 'net/http'
require 'net/https'

module KontoAPI

  mattr_accessor :api_key

  extend self

  VALIDITY_URL = Addressable::URI.parse 'https://ask.kontoapi.de/for/validity.json'
  BANKNAME_URL = Addressable::URI.parse 'https://ask.kontoapi.de/for/bankname.json'
  DEFAULT_OPTIONS = {
    :timeout  => 10
  }


  def valid?(account_number, bank_code)
    ask_for(:validity, { :ktn => account_number, :blz => bank_code })
  end

  def bank_name(bank_code)
    ask_for(:bankname, { :blz => bank_code })
  end



 private

  def ask_for(what, options={})
    raise 'Please set your API Key first (KontoAPI::api_key = "<your_key>"). You can get one at https://www.kontoapi.de/' unless api_key
    url = "#{what}_URL".upcase.constantize.dup
    options.merge!( :key => api_key )
    url.query_values = options
    body = get_url(url)
    NibblerJSON.parse(body)
  end

  def get_url(url)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
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