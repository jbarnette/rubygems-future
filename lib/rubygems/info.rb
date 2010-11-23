require "rubygems/dependency"
require "rubygems/platform"
require "rubygems/version"

module Gem

  # A tasty bite of gem metadata. Contains the bare minimum of useful
  # information about a gem. It's intended to be used as a lightweight
  # data object when Gem::Specification is too unwieldy.

  class Info

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
    # gem. Normally set only for instances created via Gem::Info.for.

    attr_reader :spec

    # This gem's version as a <tt>Gem::Version</tt>.

    attr_reader :version

    # Create an instance from a Gem::Specification.

    def self.for spec, source = nil
      new spec.name, spec.version, spec.platform, source, spec do |i|
        i.dependencies.concat spec.dependencies
      end
    end

    # Create a new instance. +platform+ is optional, and defaults to
    # +ruby+. If a block is given the new instance is yielded.

    def initialize name, version,
      platform = nil, source = nil, spec = nil, &block

      @dependencies = []
      @name         = name
      @platform     = platform || "ruby"
      @source       = source
      @spec         = spec
      @version      = Gem::Version.create version

      yield self if block_given?
    end

    # A string suitable for pretty display. Includes name, version,
    # and platform (if not ruby).

    def display
      return @display if defined? @display

      @display = "#{name}-#{version}"
      @display << "-#{platform}" unless "ruby" == platform

      @display
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
      initialize hash[:name], hash[:version], hash[:platform] do |m|
        hash[:dependencies].each do |arr|
          m.dependencies.push Gem::Dependency.new(*arr)
        end
      end
    end

    def to_s
      "#<#{self.class.name}: #{display}>"
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
