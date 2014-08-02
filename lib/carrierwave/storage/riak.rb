# encoding: utf-8
require 'carrierwave'
require 'riak'

module CarrierWave
  module Storage

    ##
    #
    #     CarrierWave.configure do |config|
    #       config.riak_host = "http://localhost
    #       config.riak_port = 8098
    #     end
    #
    #
    class Riak < Abstract

      class Connection
        def initialize(options={})
          @client = ::Riak::Client.new(options)
        end

        def store(bucket, filename, payload, headers = {})
          bucket = @client.bucket(bucket)
          robject = ::Riak::RObject.new(bucket, filename)
          robject.content_type = headers[:content_type]
          robject.raw_data = payload
          robject.store
        end

        def get(bucket, key)
          bucket = @client.bucket(bucket)
          bucket.get(key)
        end

        def delete(bucket, key)
          bucket = @client.bucket(bucket)
          bucket.delete(key)
        end

        def post(path, payload, headers = {})
          @http["#{escaped(path)}"].post(payload, headers)
        end

        def escaped(path)
          CGI.escape(path)
        end
      end

      class File < SanitizedFile
        attr_reader :uploader, :storage
        protected :uploader, :storage
        delegate :blank?, to: :file

        def initialize(uploader, storage, filename)
          @uploader = uploader
          @storage = storage
          @original_filename = filename
        end

        ##
        # Returns the path of the riak file
        #
        # === Returns
        #
        # [String] A full path to file
        #
        def path
          ::File.join('/', uploader.riak_bucket, identifier)
        end

        ##
        # Lookup value for file content-type header
        #
        # === Returns
        #
        # [String] value of content-type
        #
        def content_type
          @content_type || file.content_type
        end

        ##
        # Set non-default content-type header (default is file.content_type)
        #
        # === Returns
        #
        # [String] returns new content type value
        #
        def content_type=(new_content_type)
          @content_type = new_content_type
        end

        ##
        # Return riak meta data
        #
        # === Returns
        #
        # [Haash] A hash of X-Riak-Meta-* headers
        #
        def meta
          file.meta
        end

        ##
        # Return size of file body
        #
        # === Returns
        #
        # [Integer] size of file body
        #
        def size
          file.raw_data.length
        end

        ##
        # Reads the contents of the file from Riak
        #
        # === Returns
        #
        # [String] contents of the file
        #
        def read
          file.raw_data
        end

        ##
        # Remove the file from Riak
        #
        def delete
          begin
            riak_client.delete(uploader.riak_bucket, identifier)
            true
          rescue Exception => e
            # If the file's not there, don't panic
            nil
          end
        end

        ##
        # Writes the supplied data into Riak
        #
        # === Returns
        #
        # boolean
        #
        def store(file)
          @file = riak_client.store(uploader.riak_bucket, riak_key, file.read, {:content_type => file.content_type})
          update_filename(@file.key)
          true
        end

        def ==(other)
          self.uploader == other.uploader && self.original_filename == other.original_filename && self.storage == other.storage
        end

        private
          def riak_key
            uploader.riak_genereated_keys ? nil : identifier
          end

          def update_filename(new_filename)
            if uploader.riak_genereated_keys
              @original_filename = new_filename

              update_model_column(@original_filename)
            end
          end

          def update_model_column(new_filemame)
            if defined?(Rails) && uploader.model
              uploader.model.update_column(uploader.mounted_as.to_sym, new_filemame)
            end
          end

          def headers
            @headers ||= {  }
          end

          def connection
            @storage.connection
          end

          ##
          # lookup file
          #
          # === Returns
          #
          # [Riak::RObject] file data from remote service
          #
          def file
            @file ||= riak_client.get(uploader.riak_bucket, identifier)
          end

          def riak_client
            if @riak_client
              @riak_client
            else
              @riak_client ||= CarrierWave::Storage::Riak::Connection.new(riak_options)
            end
          end

          def riak_options
            if @uploader.riak_nodes
              {:nodes => uploader.riak_nodes}
            else
              {:host => uploader.riak_host, :http_port => uploader.riak_port}
            end
          end

      end

      ##
      # Store the file on Riak
      #
      # === Parameters
      #
      # [file (CarrierWave::SanitizedFile)] the file to store
      #
      # === Returns
      #
      # [CarrierWave::Storage::Riak::File] the stored file
      #
      def store!(file)
        f = CarrierWave::Storage::Riak::File.new(uploader, self, uploader.filename)
        f.store(file)
        f
      end

      # Do something to retrieve the file
      #
      # @param [String] identifier uniquely identifies the file
      #
      # [identifier (String)] uniquely identifies the file
      #
      # === Returns
      #
      # [CarrierWave::Storage::Riak::File] the stored file
      #
      def retrieve!(identifier)
        CarrierWave::Storage::Riak::File.new(uploader, self, identifier)
      end
    end # CloudFiles
  end # Storage
end # CarrierWave
