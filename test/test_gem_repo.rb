require "rubygems/future/test"
require "rubygems/repo"

require "mocha"

class TestGemRepo < Gem::Future::Test
  def setup
    @old_load_path = $LOAD_PATH.dup
  end

  def teardown
    $LOAD_PATH.replace @old_load_path
  end

  def test_activate
    repo do |r|
      r.gem "foo"

      assert r.activate("foo")
      assert r.activated?("foo")
      assert $LOAD_PATH.detect { |p| /foo/ =~ p }
    end
  end

  def test_activate_already_activated
    repo do |r|
      r.gem "foo"

      assert r.activate("foo")
      refute r.activate("foo")
    end
  end

  def test_activate_already_activated_different_version
    repo do |r|
      r.gem "foo", "1.0.0"
      r.gem "foo", "2.0.0"

      r.activate "foo", "1.0.0"

      ex = assert_raises LoadError do
        r.activate "foo", "2.0.0"
      end

      assert_match(/already activated/i, ex.message)
    end
  end

  def test_activate_bad_gem
    repo do |r|
      ex = assert_raises LoadError do
        r.activate "monkey"
      end

      assert_match(/can't find a gem/i, ex.message)
    end
  end

  def test_activate_bad_version
    repo do |r|
      r.gem "foo", "1.0.0"

      ex = assert_raises LoadError do
        r.activate "foo", "3.0.0"
      end

      assert_match(/but nothing/i, ex.message)
    end
  end

  def test_activate_secondary_path
    repo do |extra|
      extra.gem "bar"

      repo extra.home do |r|
        r.gem "foo"

        assert r.activate("bar")
        assert r.activate("foo")
        assert r.activated?("bar")
        assert $LOAD_PATH.detect { |p| /bar/ =~ p }
      end
    end
  end

  def test_infos
    repo do |r|
      r.gem "foo"
      r.gem "foo", "2.0.0"
      r.gem "bar"

      assert_equal %w(bar foo), r.infos.latest.map { |m| m.name }.sort
      assert_kind_of Gem::Info, r.infos.first
    end
  end

  def test_home
    assert_equal File.expand_path("path/to/repo"),
      Gem::Repo.new("path/to/repo").home
  end

  def test_paths
    repo = Gem::Repo.new "foo", "bar", "bar"
    expected = %w(foo bar).map { |f| File.expand_path f }
    assert_equal expected, repo.paths
  end

  def test_reset
    repo do |r|
      r.gem "foo"

      refute r.infos.empty?
      FileUtils.rm_rf r.home

      r.reset
      assert r.infos.empty?
    end
  end

  def test_require
    repo do |r|
      r.gem "foo" do |s|
        s.files = %w(lib/foo.rb)
      end

      r.expects(:gem_original_require).with "foo"
      r.require "foo"

      assert r.activated?("foo")
    end
  end

  def test_require_not_found
    repo do |r|
      r.expects(:gem_original_require).with "nonexistent"
      r.require "nonexistent"

      assert r.activated.empty?
    end
  end

  def test_require_secondary_path
    repo do |extra|
      extra.gem "bar" do |s|
        s.files = %w(lib/bar.rb)
      end

      repo extra.home do |r|
        r.expects(:gem_original_require).with "bar"
        r.require "bar"

        assert r.activated?("bar")
      end
    end
  end

  def test_specs
    repo do |r|
      r.gem "foo"
      r.gem "foo", "2.0.0"
      r.gem "bar"

      assert_equal %w(bar-1.0.0 foo-1.0.0 foo-2.0.0),
      r.specs.map { |s| s.full_name }.sort
    end
  end

  def test_specs_secondary_path
    repo do |extra|
      bar = extra.gem "bar"

      repo extra.home do |r|
        assert_equal [bar], r.specs.entries
      end
    end
  end
end