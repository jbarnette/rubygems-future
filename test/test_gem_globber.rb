require "rubygems/future/test"
require "rubygems/repo"

class TestGemGlobber < Gem::Future::Test
  def test_spec
    repo do |r|
      r.gem "foo" do |s|
        s.files = %w(lib/foo/bar.rb)
      end

      g = Gem::Globber.new r
      spec = g.spec "foo/bar.rb"
      assert_equal "foo", spec.name
    end
  end

  def test_spec_not_found
    repo do |r|
      g = Gem::Globber.new r
      assert_nil g.spec("nonexistent")
    end
  end
end
