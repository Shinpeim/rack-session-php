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
  # options are passed to php_session gem
  :session_file_dir => "/path/to/your/session_files",
  :internal_encoding => 'UTF-8',
  :external_encoding => 'EUC-JP',
  :encoding_option => {:undef => :replace},

  # and you can pass Rack::Session options.
  :expire_after => 10,
}

run your_awsome_rack_application
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
