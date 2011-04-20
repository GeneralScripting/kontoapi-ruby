require 'addressable/uri'
require 'yajl/json_gem'
require 'net/http'
require 'net/https'

module KontoAPI

  extend self

  RootCA          = '/etc/ssl/certs'
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
    return false if account_number.to_s.strip.empty? || bank_code.to_s.strip.empty?
    response = ask_for(:validity, { :ktn => account_number.to_s, :blz => bank_code.to_s })
    response['answer'].eql?('yes')
  end

  def bank_name(bank_code)
    return nil if bank_code.to_s.strip.empty?
    response = ask_for(:bankname, { :blz => bank_code.to_s })
    response['answer'].empty? ? nil : response['answer']
  end



 private

  def ask_for(what, options={})
    raise 'Please set your API Key first (KontoAPI::api_key = "<your_key>"). You can get one at https://www.kontoapi.de/' unless api_key
    url = const_get("#{what}_URL".upcase).dup
    options.merge!( :key => api_key )
    url.query_values = options
    body = get_url(url)
    JSON.parse(body)
  end

  def get_url(url)
    http = Net::HTTP.new(url.host, 443)
    http.use_ssl = true
    http.read_timeout = timeout
    if File.directory? RootCA
      http.ca_path = RootCA
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      http.verify_depth = 5
    else
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    response = http.get url.request_uri, 'User-agent' => 'Konto API Ruby Client'
    case response
    when Net::HTTPSuccess, Net::HTTPOK
      response.body
    else
      response.error!
    end
  end

end