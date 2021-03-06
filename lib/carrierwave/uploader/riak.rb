require 'carrierwave'
require 'riak'

module CarrierWave
  module Uploader
    class Riak < Base

      attr_accessor :key

      storage :riak

      def inspect
        "#<#{self.class.name} key=#{filename.inspect} bucket=#{riak_bucket.inspect}>"
      end

      private

      def build_versioned_key(key, version_name)
        unless version_name.nil?
          "#{version_name}_#{key}"
        else
          key
        end

      end

      def store_versions!(new_file)
        active_versions.each { |name, v|
          v.key = build_versioned_key(key, name)
          v.store!(new_file)
        }
      end

      def remove_versions!
        versions.each { |name, v|
          v.key = build_versioned_key(key, name)
          v.remove!
        }
      end

      def retrieve_versions_from_cache!(cache_name)
        versions.each { |name, v|
          v.key = build_versioned_key(key, name)
          v.retrieve_from_cache!(cache_name)
        }
      end

      def retrieve_versions_from_store!(identifier)
        versions.each { |name, v|
          v.retrieve_from_store!(build_versioned_key(identifier, name)) }
      end
    end
  end
end
