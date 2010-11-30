require "rubygems/test"
require "rubygems/repo"

class TestGemGlobber < Gem::Test
  def test_gem
    repo do |r|
      gem "foo" do |s|
        s.files = %w(lib/foo/bar.rb)
      end

      g = Gem::Globber.new r
      gem = g.gem "foo/bar.rb"

      assert_equal "foo", gem.name
    end
  end

  def test_gem_not_found
    repo do |r|
      g = Gem::Globber.new r
      assert_nil g.gem("nonexistent")
    end
  end
end
