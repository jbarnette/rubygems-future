Dir["vendor/*/lib"].each { |lib| $: << File.expand_path(lib) }
$:.push File.expand_path("../rubygems/lib")

require "rubygems" # fake

require "fileutils"
require "minitest/autorun"
require "minitest/mock"
require "rubygems/repo"
require "tmpdir"

module Gem
  module Future
    class Test < MiniTest::Unit::TestCase
      def repo *extras, &block
        repo = Gem::Repo.new Dir.mktmpdir, *extras

        def repo.gem name, version = "1.0.0", &block
          spec = Gem::Specification.new do |s|
            s.author      = "RubyGems Tests"
            s.description = "A test gem."
            s.email       = "rubygems@example.org"
            s.homepage    = "http://example.com"
            s.name        = name
            s.platform    = Gem::Platform::RUBY
            s.summary     = "A test gem summary."
            s.version     = version

            yield s if block_given?
          end

          specpath = File.join home, "specifications", spec.spec_name
          spec.loaded_from = specpath

          FileUtils.mkdir_p File.dirname(specpath)
          open(specpath, "wb") { |f| f.write spec.to_ruby }

          gempath = File.join home, "gems", spec.full_name

          spec.files.each do |f|
            path = File.join gempath, f
            FileUtils.mkdir_p File.dirname(path)
            FileUtils.touch path
          end

          spec
        end

        begin
          yield repo
        ensure
          FileUtils.rm_rf repo.home
        end

        nil
      end
    end
  end
end

