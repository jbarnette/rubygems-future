require "rubygems/dependency"
require "rubygems/package"
require "rubygems/platform"
require "rubygems/version"

module Gem

  # A tasty bite of gem metadata. Contains the bare minimum of useful
  # information about a gem. It's intended to be used as a lightweight
  # data object when Gem::Specification is too unwieldy.

  class Info

    MISSING = lambda do |info|
      raise Gem::Exception, "#{info} doesn't have a spec."
    end

    # Other gems this gem depends on. An <tt>Array</tt> of
    # <tt>Gem::Dependency</tt> entries.

    attr_reader :dependencies

    # This gem's name.

    attr_reader :name

    # This gem's platform as a <tt>String</tt>. Default is
    # <tt>"ruby"</tt>.

    attr_reader :platform

    # The Gem::Source that's responsible for this gem. Normally set
    # only for instances created by a Gem::Source.

    attr_reader :source

    # The Gem::Specification that completely represents this
    # gem. Normally only available for instances created via
    # Gem::Info.for.

    def spec
      @spec ||= @specblock.call self
    end

    # This gem's version as a <tt>Gem::Version</tt>.

    attr_reader :version

    # Create an instance from a Gem::Specification and an optional
    # +source+.

    def self.for spec, source = nil
      gem = new spec.name, spec.version, spec.platform, source do |g|
        spec
      end

      gem.dependencies.concat spec.dependencies
      gem
    end

    # Load a Gem::Info from a <tt>.gem</tt> file.

    def self.load file
      File.open file, "rb" do |f|
        Gem::Package.open f, "r" do |package|
          Gem::Info.for package.metadata
        end
      end
    end

    # Create a new instance. +platform+ is optional, and defaults to
    # +ruby+. If a block is given it'll be used to load the instance's
    # corresponding Gem::Specification.

    def initialize name, version, platform = nil, source = nil, &specblock
      @dependencies = []
      @name         = name
      @platform     = platform || "ruby"
      @source       = source
      @specblock    = specblock || MISSING
      @version      = Gem::Version.create version
    end

    # A string suitable for display and file names. Includes name,
    # version, and platform (if not ruby).

    def id
      return @id if defined? @id
      noplat = platform.nil? || platform == Gem::Platform::RUBY
      @id = noplat ? "#{name}-#{version}" : "#{name}-#{version}-#{platform}"
    end

    # :stopdoc:

    def hash
      name.hash ^ version.hash ^ platform.hash ^ dependencies.hash
    end

    def marshal_dump
      deps = dependencies.map do |d|
        [d.name, d.requirement.as_list, d.type].flatten
      end

      {
        :dependencies => deps,
        :name         => name,
        :platform     => platform,
        :version      => version.to_s,
      }
    end

    def marshal_load hash
      initialize hash[:name], hash[:version], hash[:platform]

      hash[:dependencies].each do |arr|
        dependencies.push Gem::Dependency.new(*arr)
      end
    end

    def to_s
      "#<#{self.class.name}: #{id}>"
    end

    def sorter
      [name, version, Gem::Platform::RUBY == platform ? -1 : 1]
    end

    def == other
      self.class == other.class &&
        dependencies.sort == other.dependencies.sort &&
        name == other.name &&
        platform == other.platform &&
        version == other.version
    end

    alias_method :eql?, :==

    def <=> other
      sorter <=> other.sorter
    end
  end
end
