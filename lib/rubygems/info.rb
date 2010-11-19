require "rubygems/dependency"
require "rubygems/platform"
require "rubygems/version"

module Gem

  # A tasty bite of gem metadata. A Info contains the bare minimum of
  # useful information about a gem. It's intended to be used as a
  # lightweight data object when Gem::Specification is too unwieldy.

  class Info

    # Other gems this gem depends on. An <tt>Array</tt> of
    # <tt>Gem::Dependency</tt> entries.

    attr_reader :dependencies

    # This gem's name.

    attr_reader :name

    # This gem's platform as a <tt>String</tt>.

    attr_reader :platform

    # Where this gem originated (or should be pulled from).

    attr_reader :source

    # This gem's version as a <tt>Gem::Version</tt>.

    attr_reader :version

    # Create an instance from another object that quacks like a
    # Gem::Info. Allows +source+ to be overridden.

    def self.for other, source = nil
      new other.name, other.version, other.platform, source do |m|
        m.dependencies.replace other.dependencies.dup
      end
    end

    # Create a new instance. +platform+ is optional, and defaults to
    # +ruby+. If a block is given the new instance is yielded.

    def initialize name, version, platform = "ruby", source = nil, &block
      @dependencies = []
      @name         = name
      @platform     = platform
      @source       = source
      @version      = Gem::Version.create version

      yield self if block_given?
    end

    # :nodoc:

    def hash
      name.hash ^ version.hash ^ platform.hash ^ dependencies.hash
    end

    # :nodoc:

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

    # :nodoc:

    def marshal_load hash
      initialize hash[:name], hash[:version], hash[:platform] do |m|
        hash[:dependencies].each do |arr|
          m.dependencies.push Gem::Dependency.new(*arr)
        end
      end
    end

    # :stopdoc:

    def to_s
      full  = "#{name}-#{version}"
      full << "-#{platform}" unless "ruby" == platform

      "#<#{self.class.name}: #{full}>"
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

    def <=> other
      sorter <=> other.sorter
    end
  end
end
