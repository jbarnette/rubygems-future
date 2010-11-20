require "rubygems/collection"
require "rubygems/globber"
require "rubygems/info"
require "rubygems/installable/file"
require "rubygems/load_path"
require "rubygems/resolver"
require "rubygems/source/collection"
require "rubygems/source/local"
require "rubygems/specification"
require "rubygems/version"

module Gem

  # Represents a set of gems that are available on the file system for
  # local use. Manages activation, requires, installation, and
  # uninstallation. Can also be used as a source.

  class Repo

    # A collection of Gem::Specification instances that activated
    # through this repo.

    attr_reader :activated

    # An instance of Gem::Globber which can be used to map globs/paths
    # to specs or files in this repo.

    attr_accessor :globber

    # Where does this repo live?

    attr_reader :home

    # Represents the current environment's load path. Usually wraps
    # $LOAD_PATH.

    attr_reader :load_path

    # All the paths this repo manages. Includes home and additional
    # search paths.

    attr_reader :paths

    # A source representing this repo. The repo itself quacks like a
    # source too.

    attr_reader :source

    # Create a new instance backed by +home+, a location on the file
    # system. Additional search +paths+ can be provided. If they
    # exist, they're consulted during gem activation and searches.

    def initialize home, *paths
      @activated = []
      @globber   = Gem::Globber.new self
      @home      = File.expand_path home
      @load_path = Gem::LoadPath.new
      @paths     = [home, paths].flatten.uniq.map { |p| File.expand_path p }

      sources = @paths.map { |p| Gem::Source::Local.new p }
      @source = Gem::Source::Collection.new sources
    end

    # Find a gem named +name+ matching +requirements+ and add its lib
    # directories to $LOAD_PATH. This doesn't add bin dirs.

    def activate name, *requirements
      dependency = Gem::Dependency.new name, *requirements
      return if activated? dependency

      resolver = Gem::Resolver.new(self) { |r| r.needs dependency }

      resolver.specs.each do |spec|
        current = activated.detect { |s| s.name == name }

        if current && current != spec
          message = "Can't activate #{dependency} , " +
            "already activated " + "#{current.full_name}." # FIX: stack?

          raise ::LoadError, message
        end

        activated << spec

        requires = spec.require_paths.map do |rp|
          File.join gemdir, spec.full_name, rp
        end

        load_path.add(*requires)
      end

      true
    end

    def activated? name, *requirements
      dependency   = name if Gem::Dependency === name
      dependency ||= Gem::Dependency.new name, *requirements

      activated.any? { |s| s.satisfies_requirement? dependency }
    end

    def available? name, *requirements
      source.available? name, *requirements
    end

    # This directory contains executables for gems in this repo.

    def bindir
      @bindir ||= File.join home, "bin"
    end

    # This directory contains cached .gem files for gems in this repo.

    def cachedir
      @cachedir ||= File.join home, "cache"
    end

    def display
      source.display
    end

    # This directory contains documentation for gems in this repo.

    def docdir
      @docdir ||= File.join home, "doc"
    end

    # This directory contains unpacked versions of the gems in this repo.

    def gemdir
      @gemdir ||= File.join home, "gems"
    end

    def infos
      source.infos
    end

    # To comply with Gem::Source.

    def pull name, version
      source.pull name, version
    end

    # Force this repo to reload any cached data.

    def reset
      source.reset
    end

    # Require a feature, activating a gem from this repo if
    # necessary. Activates a gem containing +feature+ and calls Ruby's
    # original +require+.

    def require feature
      spec = globber.spec feature
      activate spec.name, spec.version if spec
      gem_original_require feature # FIX
    end

    # This directory contains Ruby gemspec files for each gem in this
    # repo.

    def specdir
      @specdir ||= File.join home, "specifications"
    end

    def specs
      source.specs
    end

    # :stopdoc:

    def to_s
      "#<#{self.class.name}: #{home}>"
    end
  end
end
