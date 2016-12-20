# OmniAuth::Xero

[OmniAuth](https://github.com/intridea/omniauth) strategy for [Xero partner](http://developer.xero.com/partner/) applications.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'omniauth-xero', github: 'cushion/omniauth-xero'
```

And then execute:

```
$ bundle
```

## Usage

1. Register a public application on the [Xero developer portal](https://api.xero.com/Application/Add).
2. Become a [Xero partner](http://developer.xero.com/partner/).
3. Add Xero as an OmniAuth provider:

```ruby
use OmniAuth::Builder do
  provider :xero,
    ENV['XERO_CLIENT_ID'],
    ENV['XERO_CLIENT_SECRET'],
    private_key_file: '/path/to/privatekey.pem'
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/cushion/omniauth-xero.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

