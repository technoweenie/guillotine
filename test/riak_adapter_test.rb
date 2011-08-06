require File.expand_path('../helper', __FILE__)
require 'riak/client'

# Assumes a local dev install of riak is setup
#
#   http://wiki.basho.com/Building-a-Development-Environment.html
# 
# Riak should be accessible from:
#
#   http://localhost:8091/riak/guillotine-test
class RiakAdapterTest < Guillotine::TestCase
  BUCKET  = Riak::Client.new(:http_port => 8091)['guillotine-test']
  ADAPTER = Guillotine::Adapters::RiakAdapter.new BUCKET

  def setup
    @db = ADAPTER
  end

  def test_adding_a_link_returns_code
    code = @db.add 'abc'
    assert_equal 'abc', @db.find(code)

    BUCKET.delete Digest::SHA1.hexdigest('abc')
    BUCKET.delete code
  end

  def test_adding_duplicate_link_returns_same_code
    code = @db.add 'abc'
    assert_equal code, @db.add('abc')

    BUCKET.delete Digest::SHA1.hexdigest('abc')
    BUCKET.delete code
  end
end

