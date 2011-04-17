Konto API Ruby Library
======================

This library provides an easy way to access the Konto API (https://www.kontoapi.de/), a webservice that performs validity checks and other services regarding german bank accounts.

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

    # Check account validity: KontoAPI::valid?(account_number, bank_code)
    KontoAPI::valid?('1234567', '12312312')
    #=> false
    KontoAPI::valid?('49379110', '10010010')
    #=> true

    # Get the name of a bank by its code: KontoAPI::bank_name(bank_code)
    KontoAPI::bank_name('10010010')
    #=> 'Postbank'

Copyright
---------

Copyright (c) 2011 General Scripting - Jan Schwenzien. See LICENSE for details.