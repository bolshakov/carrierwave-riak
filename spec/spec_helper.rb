require 'rspec'
require 'rails'
require "carrierwave"
require 'carrierwave/orm/activerecord'
require 'carrierwave/processing/mini_magick'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require "carrierwave/riak"

def file_path(*paths)
  File.expand_path(File.join(File.dirname(__FILE__), 'fixtures', *paths))
end

module Rails
  class <<self
    def root
      [File.expand_path(__FILE__).split('/')[0..-3].join('/'),"spec"].join("/")
    end
  end
end

ActiveRecord::Migration.verbose = false

CarrierWave.configure do |config|
  config.storage = :riak
  config.riak_bucket = "rspec"
  config.riak_host = "localhost"
end

def load_file(fname)
  File.open([Rails.root,fname].join("/"))
end
