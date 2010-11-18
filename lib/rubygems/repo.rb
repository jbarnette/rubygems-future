require "rubygems/globber"
require "rubygems/installable"
require "rubygems/load_path"
require "rubygems/info"
require "rubygems/resolver"
require "rubygems/source"
require "rubygems/specification"
require "rubygems/collection"

module Gem

  # Represents a set of gems that are available on the file system for
  # local use. Manages activation, requires, installation, and
  # uninstallation. Can also be used as a source.

  class Repo
    include Gem::Source

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

    # Create a new instance backed by +home+, a location on the file
    # system. Additional search +paths+ can be provided. If they
    # exist, they're consulted during gem activation and searches.

    def initialize home, *paths
      @activated = []
      @globber   = Gem::Globber.new self
      @load_path = Gem::LoadPath.new
      @paths     = [home, paths].flatten.uniq.map { |p| File.expand_path p }
      @home      = File.expand_path home
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
          File.join home, "gems", spec.full_name, rp
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
      !infos.search(name, *requirements).empty?
    end

    # To comply with Gem::Source.

    def pull name, version
      spec = specs.search(name, "= #{version}").first
      raise ::LoadError, "Can't find #{name}-#{version}." unless spec

      file = gemfiles.detect do |f|
        "#{name}-#{version}"  == File.basename(f, ".gem")
      end

      raise ::LoadError, "Missing Gem file [#{file}." unless file
      Gem::Installable.new spec, file
    end

    # Force this repo to reload any cached data or assumptions.

    def reset
      @infos = nil
      @specs = nil
    end

    # Require a feature, activating a gem from this repo if
    # necessary. Activates a gem containing +feature+ and calls Ruby's
    # original +require+.

    def require feature
      spec = globber.spec feature
      activate spec.name, spec.version if spec
      gem_original_require feature
    end

    # Return a collection of Gem::Specification\s. See Gem::Collection
    # for examples of how this collection is searchable.

    def specs
      @specs ||= Gem::Collection.new(specfiles.map { |file|
        Gem::Specification.load file
      })
    end

    # :stopdoc:

    def gemfiles
      Dir["{#{paths.join ','}}/cache/*.gem"]
    end

    def specfiles
      Dir["{#{paths.join ','}}/specifications/*.gemspec"]
    end

    def to_s
      "#<#{self.class.name}: #{home}>"
    end
  end
end
