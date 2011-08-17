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
        sha      = Digest::SHA1.hexdigest url
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
        if obj = @code_bucket.get(code, :r => 1)
          obj.data
        end
      rescue Riak::FailedRequest => err
        raise unless err.not_found?
      end
    end
  end
end

