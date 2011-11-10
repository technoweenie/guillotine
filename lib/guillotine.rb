require 'base64'
require 'digest/md5'
require 'addressable/uri'

module Guillotine
  VERSION = "1.0.4"

  dir = File.expand_path '../guillotine', __FILE__
  autoload :App, "#{dir}/app"

  class DuplicateCodeError < StandardError
    attr_reader :existing_url, :new_url, :code

    def initialize(existing_url, new_url, code)
      @existing_url = existing_url
      @new_url      = new_url
      @code         = code
      super "#{@new_url.inspect} was supposed to be shortened to #{@code.inspect}, but #{@existing_url.inspect} already is!"
    end
  end

  module Adapters
    dir = File.expand_path '../guillotine/adapters', __FILE__
    autoload :MemoryAdapter,       "#{dir}/memory_adapter"
    autoload :SequelAdapter,       "#{dir}/sequel_adapter"
    autoload :RiakAdapter,         "#{dir}/riak_adapter"
    autoload :ActiveRecordAdapter, "#{dir}/active_record_adapter"
    autoload :MongoAdapter,        "#{dir}/mongo_adapter"

    # Adapters handle the storage and retrieval of URLs in the system.  You can
    # use whatever you want, as long as it implements the #add and #find
    # methods.  See MemoryAdapter for a simple solution.
    class Adapter
      # Public: Shortens a given URL to a short code.
      #
      # 1) MD5 hash the URL to the hexdigest
      # 2) Convert it to a Bignum
      # 3) Pack it into a bitstring as a big-endian int
      # 4) base64-encode the bitstring, remove the trailing junk
      #
      # url - String URL to shorten.
      #
      # Returns a unique String code for the URL.
      def shorten(url)
        Base64.urlsafe_encode64([Digest::MD5.hexdigest(url).to_i(16)].pack("N")).sub(/==\n?$/, '')
      end

      # Parses and sanitizes a URL.
      #
      # url - A String URL.
      #
      # Returns an Addressable::URI.
      def parse_url(url)
        url.gsub! /\s/, ''
        url.downcase!
        Addressable::URI.parse url
      end
    end
  end
end
