require File.expand_path('../helper', __FILE__)

class TransitionAdapterTest < Guillotine::TestCase
  def setup
    @old = Guillotine::MemoryAdapter.new
    @new = Guillotine::MemoryAdapter.new
    @db = Guillotine::TransitionAdapter.new @new, @old
  end

  def test_adding_a_link_returns_code
    code = @db.add "url"
    assert_equal "url", @db.find(code)
    assert_equal "url", @new.find(code)
    assert_equal "url", @old.find(code)
  end

  def test_finds_code_from_new_adapter
    @new.add "new", "code"
    @old.add "old", "code"
    assert_equal "new", @db.find("code")
  end

  def test_fills_code_to_new_adapter
    @old.add "url", "code"
    assert_nil @new.find("code")
    assert_equal "url", @db.find("code")
    assert_equal "url", @new.find("code")
  end

  def test_adding_duplicate_link_returns_same_code
    code = @db.add "url"
    assert_equal code, @db.add("url")
  end

  def test_adds_url_with_custom_code
    assert_equal "code", @db.add("def", "code")
    assert_equal "def", @db.find("code")
  end

  def test_clashing_urls_raises_error
    @old.add "url", "code"
    assert_raises Guillotine::DuplicateCodeError do
      @db.add "url2", "code"
    end
  end

  def test_missing_code
    assert_nil @db.find("missing")
  end

  def test_gets_code_from_new_adapter
    code = @new.add "url"
    assert_equal code, @db.code_for("url")
  end

  def test_fills_url_to_new_adapter
    code = @old.add "url", "code"
    assert_nil @new.code_for("url")
    assert_equal "code", @db.code_for("url")
    assert_equal "code", @new.code_for("url")
  end

  def test_clears_code_for_url
    @new.add "url", "code"
    @old.add "url", "code"

    assert_equal "url", @new.find("code")
    assert_equal "url", @old.find("code")
    assert_equal "url", @db.find("code")

    @db.clear "url"

    assert_nil @new.find("code")
    assert_nil @old.find("code")
    assert_nil @db.find("code")
  end
end
