require 'digest/sha1'

module Guillotine
  module Adapters
    # Stores shortened URLs in Riak.  Totally scales.
    class RiakAdapter < Adapter
      attr_reader :code_bucket, :url_bucket

      # Initializes the adapter.
      #
      # code_bucket - The Riak::Bucket for all code keys.
      # url_bucket  - The Riak::Bucket for all url keys.  If this is not
      #               given, the code bucket is used for all keys.
      def initialize(code_bucket, url_bucket = nil)
        @code_bucket = code_bucket
        @url_bucket  = url_bucket || @code_bucket
      end

      # Public: Stores the shortened version of a URL.
      # 
      # url  - The String URL to shorten and store.
      # code - Optional String code for the URL.
      #
      # Returns the unique String code for the URL.  If the URL is added
      # multiple times, this should return the same code.
      def add(url, code = nil)
        sha      = url_key url
        url_obj  = @url_bucket.get_or_new sha, :r => 1
        url_obj.data || begin
          code        ||= shorten url
          code_obj      = @code_bucket.get_or_new code
          if existing_url = code_obj.data # key exists
            raise DuplicateCodeError.new(existing_url, url, code) if existing_url != url
          end
          code_obj.content_type = url_obj.content_type = 'text/plain'
          code_obj.data = url
          url_obj.data  = code
          code_obj.store
          url_obj.store
          code
        end
      end

      # Public: Retrieves a URL from the code.
      #
      # code - The String code to lookup the URL.
      #
      # Returns the String URL.
      def find(code)
        if obj = url_object(code)
          obj.data
        end
      end

      # Public: Retrieves the code for a given URL.
      #
      # url - The String URL to lookup.
      #
      # Returns the String code, or nil if none is found.
      def code_for(url)
        if obj = code_object(url)
          obj.data
        end
      end

      # Public: Removes the assigned short code for a URL.
      #
      # url - The String URL to remove.
      #
      # Returns nothing.
      def clear(url)
        if code_obj = code_object(url)
          @url_bucket.delete  code_obj.key
          @code_bucket.delete code_obj.data
        end
      end

      # Retrieves a URL riak value from the code.
      #
      # code - The String code to lookup the URL.
      #
      # Returns a Riak::RObject, or nil if none is found.
      def url_object(code)
        @code_bucket.get(code, :r => 1)
      rescue Riak::FailedRequest => err
        raise unless err.not_found?
      end

      # Retrieves the code riak value for a given URL.
      #
      # url - The String URL to lookup.
      #
      # Returns a Riak::RObject, or nil if none is found.
      def code_object(url)
        sha = url_key url
        @url_bucket.get(sha, :r => 1)
      rescue Riak::FailedRequest => err
        raise unless err.not_found?
      end

      def url_key(url)
        Digest::SHA1.hexdigest url
      end
    end
  end
end

