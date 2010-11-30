require "rubygems/test"
require "rubygems/info"
require "rubygems/specification"

class TestGemInfo < Gem::Test
  def test_dependencies
    assert_equal [], Gem::Info.new("foo", "1.0.0").dependencies
  end

  def test_equality
    a = Gem::Info.new "foo", "1.0.0"
    b = a.dup
    c = Gem::Info.new "foo", "1.0.1"
    
    assert_equal a, b
    refute_equal a, c

    assert a.eql?(b)
  end

  def test_equality_unsorted_dependencies
    bar = Gem::Dependency.new "bar", "1.0.0"
    baz = Gem::Dependency.new "baz", "1.0.0"

    a = Gem::Info.new "foo", "1.0.0" do |m|
      m.dependencies.concat [bar, baz]
    end

    b = Gem::Info.new "foo", "1.0.0" do |m|
      m.dependencies.concat [baz, bar]
    end

    assert_equal a, b
  end

  def test_hash
    assert_equal Gem::Info.new("foo", "1.0.0").hash,
    Gem::Info.new("foo", "1.0.0").hash

    refute_equal Gem::Info.new("foo", "1.0.0").hash,
      Gem::Info.new("foo", "1.0.1").hash
  end

  def test_id
    assert_equal "foo-1.0.0", Gem::Info.new("foo", "1.0.0").id

    assert_equal "foo-1.0.0-jruby",
      Gem::Info.new("foo", "1.0.0", "jruby").id
  end

  def test_marshal_dump
    expected = {
      :name         => "foo",
      :version      => "1.0.0",
      :platform     => "jruby",
      :dependencies => [["bar", "= 1.0.0", :runtime],
                        ["baz", "> 2.0", "< 3.0", :development]]
    }

    info = Gem::Info.new "foo", "1.0.0", "jruby"

    info.dependencies.push Gem::Dependency.new("bar", "1.0.0")

    info.dependencies.push Gem::Dependency.
        new("baz", "> 2.0", "< 3.0", :development)


    assert_equal expected, info.marshal_dump
  end

  def test_marshal_load
    unmarshaled = {
      :name         => "foo",
      :version      => "1.0.0",
      :platform     => "jruby",
      :dependencies => [["bar", "= 1.0.0", :runtime],
                        ["baz", "> 2.0", "< 3.0", :development]]
    }

    info = Gem::Info.allocate
    info.marshal_load unmarshaled

    assert_equal "foo", info.name
    assert_equal v("1.0.0"), info.version
    assert_equal "jruby", info.platform

    bar = Gem::Dependency.new "bar", "= 1.0.0"
    baz = Gem::Dependency.new "baz", "> 2.0", "< 3.0", :development

    assert_equal [bar, baz], info.dependencies
  end

  def test_name
    assert_equal "foo", Gem::Info.new("foo", "1.0.0").name
  end

  def test_platform
    assert_equal "jruby",
      Gem::Info.new("foo", "1.0.0", "jruby").platform
  end

  def test_platform_default
    assert_equal Gem::Platform::RUBY,
      Gem::Info.new("foo", "1.0.0").platform
  end

  def test_self_for
    a = Gem::Info.new "a", "1"
    assert_equal a, Gem::Info.for(a)
  end

  def test_spaceship_name
    a = Gem::Info.new "a", "1"
    b = Gem::Info.new "b", "1"

    assert_equal(-1, (a <=> b))
    assert_equal  0, (a <=> a)
    assert_equal  1, (b <=> a)
  end

  def test_spaceship_platform
    a = Gem::Info.new "a", "1"
    b = Gem::Info.new "a", "1", "x86-my-platform1"

    assert_equal(-1, (a <=> b))
    assert_equal  0, (a <=> a)
    assert_equal  1, (b <=> a)
  end

  def test_spaceship_version
    a = Gem::Info.new "a", "1"
    b = Gem::Info.new "a", "2"

    assert_equal(-1, (a <=> b))
    assert_equal  0, (a <=> a)
    assert_equal  1, (b <=> a)
  end

  def test_to_s
    a = Gem::Info.new "foo", "1.0.0"
    assert_match(/Gem::Info/, a.to_s)
    assert_match(a.id, a.to_s)
  end

  def test_version
    assert_equal v("1.0.0"), Gem::Info.new("foo", "1.0.0").version
  end
end
