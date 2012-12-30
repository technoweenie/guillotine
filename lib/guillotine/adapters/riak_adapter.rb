require 'digest/sha1'

module Guillotine
  # Stores shortened URLs in Riak.  Totally scales.
  class RiakAdapter < Adapter
    PLAIN = 'text/plain'.freeze
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
    # url     - The String URL to shorten and store.
    # code    - Optional String code for the URL.
    # options - Optional Guillotine::Service::Options
    #
    # Returns the unique String code for the URL.  If the URL is added
    # multiple times, this should return the same code.
    def add(url, code = nil, options = nil)
      sha     = url_key url
      url_obj = @url_bucket.get_or_new sha, :r => 1
      if url_obj.raw_data
        fix_url_object(url_obj)
        code = url_obj.data
      end

      code = get_code(url, code, options)
      code_obj = @code_bucket.get_or_new code
      code_obj.content_type = url_obj.content_type = PLAIN

      if existing_url = code_obj.data # key exists
        raise DuplicateCodeError.new(existing_url, url, code) if url_key(existing_url) != sha
      end

      if !url_obj.data # unsaved
        url_obj.data = code
        url_obj.store
      end

      code_obj.data = url
      code_obj.store
      code
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

    # Public: Removes the assigned short code.
    #
    # code - The String code to remove.
    #
    # Returns nothing.
    def clear_code(code)
      if url_obj = url_object(code)
        @url_bucket.delete url_key(url_obj.data)
        @code_bucket.delete url_obj.key
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
      if o = @url_bucket.get(sha, :r => 1)
        fix_url_object(o)
      end
    rescue Riak::FailedRequest => err
      raise unless err.not_found?
    end

    # Fixes a bug in Guillotine 1.0.2 where the content type on url objects
    # was not being set.  The ruby Riak::Client defaults to JSON, so
    # strings were being saved as "somecode", which is unparseable by JSON.
    def fix_url_object(obj, data = nil)
      if data
        obj.content_type = PLAIN
        obj.data = data
        obj.store
        return obj
      end
      case obj.content_type
        when /json/ then fix_url_object(obj, JSON.parse(%({"data":#{obj.raw_data}}))['data'])
        when PLAIN  then obj
        else fix_url_object(obj, obj.data) # old values had the right data but the content type was application/x-www-form-urlencoded
      end
    end

    def url_key(url)
      Digest::SHA1.hexdigest url.downcase
    end
  end
end

