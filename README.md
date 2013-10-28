# Rack::Session::PHP
[![Build Status](https://travis-ci.org/Shinpeim/rack-session-php.png?branch=master)](https://travis-ci.org/Shinpeim/rack-session-php)

This module provides PHP compatible session in rack layer.

## Installation

Add this line to your application's Gemfile:

    gem 'rack-session-php'

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install rack-session-php

## Usage

In your config.ru

```
require 'rack/session/php'

use Rack::Session::PHP, {
  :session_file_dir => "/path/to/your/session_files"
  :file_options => {
    :internal_encoding => 'UTF-8', # encoding in ruby is utf-8
    :external_encoding => 'EUC-JP',# encoding in session file is euc-jp
    :encoding_option => {:undef => :replace}, # option passed to String#encode
  }
  :expire_after => 10,
  # and you can pass Rack::Session options.
}

run your_awsome_rack_application
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
