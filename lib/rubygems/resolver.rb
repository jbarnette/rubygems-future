require "set"
require "tsort"

module Gem

  # A really, really stupid resolver stub. Doesn't do source pinning,
  # platforms, or really much of anything. Just a placeholder to play
  # with API.

  class Resolver
    include TSort

    attr_reader :sources

    # Initialize a resolver, providing the initial set of +sources+ to
    # use for resolution. Sources can be anything that quacks like
    # Gem::Source, so it's perfectly reasonable to, e.g., use a
    # resolver against a Gem::Repo during activation or a Gem::Source
    # during installation.

    def initialize *sources, &block
      @sources = sources.flatten
      @entries = Set.new

      yield self if block_given?
    end

    def needs name, requirement = nil
      dependency   = name if Gem::Dependency === name
      dependency ||= Gem::Dependency.new name, requirement

      @entries |= get([dependency], :all)
    end

    def get dependencies, dev = false
      dependencies.reject! { |d| :development == d.type } unless dev

      dependencies.map do |dep|
        candidates = search dep.name, dep.requirement

        if candidates.empty?
          others = search dep.name
          message = "Can't find a gem for #{dep}."

          unless others.empty?
            versions = others.map { |o| o.version }
            message = "Found #{dep.name} (#{versions.join ', '}), " +
              "but nothing #{dep.requirement}."
          end

          raise ::LoadError, message
        end

        candidates.first
      end
    end

    def search name, *requirements
      results = sources.map do |source|
        source.gems.search name, *requirements
      end

      results.inject { |m, i| m.concat i }
    end

    def tsort_each_node &block
      @entries.each(&block)
    end

    def tsort_each_child node, &block
      get(node.dependencies).each(&block)
    end

    alias_method :gems, :tsort
  end
end
