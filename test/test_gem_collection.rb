require "rubygems/future/test"
require "rubygems/info"
require "rubygems/collection"

class TestGemCollection < Gem::Future::Test
  def test_by
    a = entry "foo", "1.0.0"
    b = entry "foo", "2.0.0"

    specs = Gem::Collection.new [a, b]

    expected = { "foo" => Gem::Collection.new([a, b]) }
    assert_equal expected, specs.by(:name)
  end

  def test_initialize
    specs = Gem::Collection.new x = []
    assert_same x, specs.entries
  end

  def test_initialize_array
    specs = Gem::Collection.new [entry("foo", "1.0.0")]

    assert_equal 1, specs.count
    assert_equal 1, specs.length
    assert_equal 1, specs.size
  end

  def test_latest
    a  = entry "foo", "1.0.0"
    ap = entry "foo", "2.0.0.pre"
    a1 = entry "foo", "2.0.0"

    specs = Gem::Collection.new [a, ap, a1]
    assert_equal 1, specs.latest.size
    assert_equal a1, specs.latest.first
  end

  def test_prerelease
    a = entry "foo", "1.0.0"
    b = entry "foo", "2.0.0.pre"

    specs = Gem::Collection.new [a, b]
    assert_equal 2, specs.size
    assert_equal 1, specs.prerelease.size
    assert_equal b, specs.prerelease.first
  end

  def test_prerelease_latest
    a = entry "foo", "1.0.0.pre.1"
    b = entry "foo", "1.0.0.pre.2"
    c = entry "bar", "1.0.0"

    specs = Gem::Collection.new [a, b, c]
    assert_equal [b], specs.prerelease.latest.entries
  end

  def test_released
    a = entry "foo", "1.0.0"
    b = entry "foo", "2.0.0.pre"

    specs = Gem::Collection.new [a, b]
    assert_equal 2, specs.size
    assert_equal 1, specs.released.size
    assert_equal a, specs.released.first
  end

  def test_search
    a = entry "foo", "1.0.0"
    b = entry "bar", "1.0.0"

    specs = Gem::Collection.new [a, b]

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

  def test_to_s
    c = Gem::Collection.new entry("foo", "1.0.0")
    assert_match(/Gem::Collection/, c.to_s)
    assert_match(/foo/, c.to_s)
  end

  def test_uniq
    a = entry "foo", "1.0.0"
    b = a.dup
    c = Gem::Collection.new [a, b]

    assert_equal Gem::Collection.new([a]), c.uniq
  end

  def test_uniq!
    a = entry "foo", "1.0.0"
    b = a.dup
    c = Gem::Collection.new [a, b]
    u = c.uniq!

    assert_same c, u
    assert_equal [a], u.entries
  end

  def entry name, version, platform = nil
    Gem::Info.new name, version, platform
  end
end
