# CarrierWave for [Riak](http://wiki.basho.com/Riak.html)

This gem adds storage support for [Riak](http://wiki.basho.com/Riak.html) to [CarrierWave](https://github.com/jnicklas/carrierwave/)

This module should work for basic uploads, but hasn't been tested with all features of carrierrwave and is very new.  The code was initially based
on [carrierwave-upyun](https://github.com/nowa/carrierwave-upyun) but also uses ideas taken from the built in Fog storage provider.

## Installation

    gem install carrierwave-riak

## Or using Bundler, in `Gemfile`

    gem 'riak-client'
    gem 'carrierwave-riak', :require => "carrierwave/riak"

## Configuration

You'll need to configure the Riak client in config/initializers/carrierwave.rb

```ruby
CarrierWave.configure do |config|
  config.storage = :riak
  config.asset_host = "http://example.com"
  config.riak_backet = 'yellow_bucket'
  config.riak_host = 'localhost'
  config.riak_port = 8098
end
```

or, if you use claster of nodes pass `riak_host` options instead of `riak_host` and `riak_port`

```ruby
CarrierWave.configure do |config|
  # ...
  config.riak_nodes = [
    { host: "127.0.0.1", http_port: 8098 }, 
    { host: "127.0.0.1", http_port: 8099 }
  ]
end
```

To overwrite `riak_bucket` for specific uploader (See [https://github.com/carrierwaveuploader/carrierwave/wiki/How-to:-Define-different-storage-configuration-for-each-Uploader.](carrierwave wiki) for details):

If you need to have Riak generated keys, use `riak_genereated_keys` option:
 
```ruby
CarrierWave.configure do |config|
  # ...
  config.riak_genereated_keys = true
end
``` 

```ruby
class AvatarUploader < CarrierWave::Uploader::Riak
  storage :riak

  # define some uploader specific configurations in the initializer
  # to override the global configuration
  def initialize(*)
    super
    self.riak_bucket = 'another_bucket'
  end
end
```

## Usage example

Note that for your uploader, your should extend the `CarrierWave::Uploader::Riak` class.

### Using Riak generated keys ###

Because the orm record is saved before the storage object is, the orm record needs to be updated after
saving to storage if a Riak generated key is to be used as the identifier.  The CarrierWave::Uploader::Riak
class defines an :after callback to facilitate this.  This only works for ActiveRecord and is likely pretty
hacky.  Maybe someone can suggest a better way to deal with this.

## TODO ###

- Write specs.  Bad programmer.

## Contributing ##

If this is helpful to you, but isn't quite working please send me pull requests.
