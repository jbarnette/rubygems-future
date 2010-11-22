require "rubygems/future/test"
require "rubygems/collection"
require "rubygems/info"

class TestGemFilter < Gem::Future::Test
  def test_by
    a = entry "foo", "1.0.0"
    b = entry "foo", "2.0.0"
    c = filter a, b

    expected = { "foo" => [a, b] }
    assert_equal expected, c.by(:name)
  end

  def test_empty?
    assert filter.empty?
    refute filter(:x).empty?
  end

  def test_equality
    a = filter
    b = filter

    assert_equal a, b
    refute_equal a, filter(:x)
    refute_equal a, a.latest
    refute_equal a, a.prerelease
    refute_equal a, a.released
  end

  def test_latest
    a = entry "foo", "1.0.0"
    b = entry "foo", "2.0.0"
    c = filter a, b

    assert_equal [b], c.latest.entries
  end

  def test_latest?
    f = filter
    f.latest!
    assert f.latest?
  end

  def test_latest!
    a = entry "foo", "1.0.0"
    b = entry "foo", "2.0.0"
    c = filter a, b

    c.latest!
    assert_equal [b], c.entries
  end

  def test_prerelease
    a = entry "foo", "1.0.0"
    b = entry "bar", "1.0.0.pre"
    c = filter a, b

    assert_equal [b], c.prerelease.entries
  end

  def test_prerelease?
    f = filter
    f.prerelease!
    assert f.prerelease?
  end

  def test_prerelease!
    a = entry "foo", "1.0.0"
    b = entry "bar", "1.0.0.pre"
    c = filter a, b

    c.prerelease!
    assert_equal [b], c.entries
  end

  def test_released
    a = entry "foo", "1.0.0"
    b = entry "bar", "1.0.0.pre"
    c = filter a, b

    assert_equal [a], c.released.entries
  end

  def test_released?
    f = filter
    f.released!
    assert f.released?
  end

  def test_released!
    a = entry "foo", "1.0.0"
    b = entry "bar", "1.0.0.pre"
    c = filter a, b

    c.released!
    assert_equal [a], c.entries
  end

  def test_search
    a = entry "foo", "1.0.0"
    b = entry "bar", "1.0.0"

    specs = filter a, b

    assert_equal [a], specs.search("foo").entries
    assert_equal [b], specs.search("bar").entries
  end

  def test_search_regexp
    a = entry "foobar", "1.0.0"
    b = entry "foobaz", "1.0.0"

    specs = Gem::Collection.new [a, b]
    assert_equal [a, b], specs.search(/foo/).sort
  end

  def test_search_requirement
    a = entry "foo", "1.0.0"
    b = entry "foo", "2.0.0"

    specs = Gem::Collection.new [a, b]
    assert_equal [b], specs.search("foo", "> 1.0.0").entries
  end

  def test_search_platform
    a = entry "foo", "1.0.0"
    b = entry "foo", "1.0.0", "jruby"

    specs = Gem::Collection.new [a, b]
    assert_equal [b], specs.search("foo", :platform => "jruby").entries
  end

  def test_search_narrowed
    a = entry "foo", "1.0.0"
    b = entry "foo", "1.0.0.pre"

    specs = Gem::Collection.new [a, b]
    assert_equal [b], specs.prerelease.search("foo").entries
  end

  def test_unique
    a = entry "foo", "1.0.0"
    b = entry "foo", "1.0.0"
    c = filter a, b

    assert_equal [a], c.unique.entries
  end

  def test_unique!
    a = entry "foo", "1.0.0"
    b = entry "foo", "1.0.0"
    c = filter a, b

    c.unique!
    assert_equal [a], c.entries
  end

  def entry name, version, platform = nil
    Gem::Info.new name, version, platform
  end

  def filter *args, &block
    Gem::Collection.new args, &block
  end
end
