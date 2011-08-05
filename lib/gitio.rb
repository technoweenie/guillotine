require 'base64'
require 'digest/md5'

module Gitio
  VERSION = "0.0.1"

  dir = File.expand_path '../gitio', __FILE__
  autoload :App, "#{dir}/app"

  module Adapters
    dir = File.expand_path '../gitio/adapters', __FILE__
    autoload :MemoryAdapter, "#{dir}/memory_adapter"
    autoload :SequelAdapter, "#{dir}/sequel_adapter"

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
    end
  end
end
