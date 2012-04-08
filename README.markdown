Konto API Ruby Library
======================

This library provides an easy way to access the [Konto API](https://www.kontoapi.de/), a webservice that performs validity checks and other services regarding german and international bank accounts.

INSTALLATION
------------

    $ [sudo] gem install kontoapi-ruby

USAGE
-----

    require 'kontoapi-ruby'

    # mendatory settings
    KontoAPI::api_key = "abc123"

    # optional settings
    KontoAPI::timeout = 10   # 10 seconds is the default

    # Check account validity: KontoAPI::valid?(options)
    KontoAPI::valid?( :ktn => '1234567', :blz => '12312312' )
    #=> false
    KontoAPI::valid?( :ktn => '49379110', :blz => '10010010' )
    #=> true
    
    # Check IBAN only
    KontoAPI::valid?( :iban => 'DE71100100100068118106' )
    #=> true
    
    # Check BIC only
    KontoAPI::valid?( :bic => 'PBNKDEFF100' )
    #=> true
    
    # Check both IBAN and BIC
    KontoAPI::valid?( :iban => 'DE71100100100068118106', :bic => 'PBNKDEFF100' )
    #=> true

    # Get the name of a bank by its code: KontoAPI::bank_name(bank_code)
    KontoAPI::bank_name('10010010')
    #=> 'Postbank'

Copyright
---------

Copyright (c) 2011 General Scripting - Jan Schwenzien. See LICENSE for details.