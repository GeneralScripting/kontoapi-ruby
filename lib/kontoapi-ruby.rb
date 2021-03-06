require 'addressable/uri'
require 'yajl'
require 'net/http'
require 'net/https'

module KontoAPI

  extend self

  RootCA            = '/etc/ssl/certs'
  VALIDITY_URL      = Addressable::URI.parse 'https://ask.kontoapi.de/for/validity.json'
  BANKNAME_URL      = Addressable::URI.parse 'https://ask.kontoapi.de/for/bankname.json'
  IBAN_AND_BIC_URL  = Addressable::URI.parse 'https://ask.kontoapi.de/for/iban_and_bic.json'
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

  def valid?(options={})
    return false  unless (!options[:ktn].to_s.strip.empty? && !options[:blz].to_s.strip.empty?) || !options[:iban].to_s.strip.empty? || !options[:bic].to_s.strip.empty?
    response = ask_for(:validity, options)
    response['answer'].eql?('yes')
  end

  def bank_name(bank_code)
    return nil if bank_code.to_s.strip.empty?
    response = ask_for(:bankname, { :blz => bank_code.to_s })
    response['answer'].empty? ? nil : response['answer']
  end

  def iban_and_bic(ktn, blz)
    stripped_ktn = ktn.to_s.strip
    stripped_blz = blz.to_s.strip
    return nil if stripped_ktn.empty?
    return nil if stripped_blz.empty?
    response = ask_for(:iban_and_bic, { :ktn => stripped_ktn, :blz => stripped_blz })
    response['answer']
  end



 private

  def ask_for(what, options={})
    raise 'Please set your API Key first (KontoAPI::api_key = "<your_key>"). You can get one at https://www.kontoapi.de/' unless api_key
    url = const_get("#{what}_URL".upcase).dup
    options.merge!( :key => api_key )
    url.query_values = options
    body = get_url(url)
    parser = Yajl::Parser.new
    parser.parse(body)
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