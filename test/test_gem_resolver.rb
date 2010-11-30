require "rubygems/test"
require "rubygems/repo"
require "rubygems/resolver"

class TestGemResolver < Gem::Test
  def test_specs_simplest
    repo do |r|
      # gem "foo"
      # gem "foo", "2.0.0"

      # resolver = Gem::Resolver.new r do |res|
      #   res.needs "foo"
      # end

      # specs = resolver.specs
      # spec  = specs.first

      # assert_equal 1, specs.size
      # assert_equal "foo", spec.name
      # assert_equal Gem::Version.new("2.0.0"), spec.version
    end
  end
end
