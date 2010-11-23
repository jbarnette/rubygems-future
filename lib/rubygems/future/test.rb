Dir["vendor/*/lib"].each { |lib| $: << File.expand_path(lib) }
$:.push File.expand_path("../rubygems/lib")

if ENV["COVERAGE"]
  module Gem; end

  require "rubygems/version"
  require "simplecov"

  SimpleCov.start do
    add_filter "/lib/rubygems.rb"
    add_filter "/test/"
    add_filter "/vendor/"
  end
end

require "rubygems"

Gem::DefaultUserInteraction.ui = Gem::SilentUI.new

require "fileutils"
require "minitest/autorun"
require "minitest/mock"
require "rubygems/repo"
require "tmpdir"

module Gem
  module Future
    class Test < MiniTest::Unit::TestCase

      # Construct a new Gem::Dependency.

      def dep name, *requirements
        Gem::Dependency.new name, *requirements
      end

      # Construct a real live gem in a repo! Looks to use @repo first,
      # then at <tt>options[:repo]</tt>. Expects the default
      # implementation of Gem::Repo, which uses the filesystem. If
      # <tt>options[:cache]</tt> is true, a built version of the gem
      # will be put in the repo's cache dir. All files will be empty.

      def gem name, version = nil, options = nil, &block
        if Hash === version && !options
          options = version
          version = nil
        end

        options ||= {}
        version ||= "1.0.0"

        repo = options[:repo] || @repo
        repo or raise "Need a repo or @repo to make a gem."

        s = spec(name, version, &block)

        specpath = File.join repo.specdir, s.spec_name
        s.loaded_from = specpath

        FileUtils.mkdir_p File.dirname(specpath)
        open(specpath, "wb") { |f| f.write s.to_ruby }

        gempath = File.join repo.gemdir, s.full_name
        FileUtils.mkdir_p gempath

        s.files.each do |f|
          path = File.join gempath, f
          FileUtils.mkdir_p File.dirname(path)
          FileUtils.touch path
        end

        if options[:cache]
          FileUtils.mkdir_p repo.cachedir
          gemfile s, gempath, File.join(repo.cachedir, s.file_name)
        end

        repo.reset
        repo.gem name, version
      end

      # Use +spec+ and the unpacked version of the spec in the
      # +source+ dir to create a .gem file and drop it in the
      # +destination+ directory. If a destination isn't specified the
      # file gets dropped in the current directory.

      def gemfile spec, source, destination = nil
        destination ||= File.expand_path "."

        require "rubygems/builder"

        Dir.chdir source do
          FileUtils.mv Gem::Builder.new(spec).build, destination
        end

        destination
      end

      # Create a real live repo on disk, in a temp dir. Cleaned up at
      # the end of +block+, which gets yielded the Gem::Repo
      # instance. any +extras+ are passed along to Gem::Repo.new.

      def repo *extras, &block
        old_repo = @repo if defined? @repo
        @repo = repo = Gem::Repo.new(Dir.mktmpdir, *extras)

        begin
          yield repo
        ensure
          @repo = old_repo
          FileUtils.rm_rf repo.home
        end

        nil
      end

      # Construct a new Gem::Requirement.

      def req *requirements
        return requirements.first if Gem::Requirement === requirements.first
        Gem::Requirement.create requirements
      end

      # Construct a new Gem::Specification.

      def spec name, version, &block
        Gem::Specification.new name, v(version) do |s|
          s.author      = "RubyGems Future Tests"
          s.description = "A test gem."
          s.email       = "rubygems@example.org"
          s.homepage    = "http://example.com"
          s.platform    = Gem::Platform::RUBY
          s.summary     = "A test gem summary."

          yield s if block_given?
        end
      end

      # Construct a new Gem::Version.

      def v string
        Gem::Version.create string
      end
    end
  end
end

