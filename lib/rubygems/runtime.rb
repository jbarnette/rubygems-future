module Gem

  # Represents the entire RubyGems runtime. Coordinates between
  # sources and repos. Entry point for most commands. Knows how to
  # enable and disable itself for global (gem, require) use.

  class Runtime

    # The local repo this runtime manages.

    attr_accessor :repo

    # A Gem::Source::Collection allowing combined searches of all the
    # sources this runtime knows about.

    attr_reader :source

    def initialize repo
      @repo    = repo
      @source  = Gem::Source::Collection.new
    end

    def gem name, *requirements
      @repo.activate name, *requirements
    end

    def require feature
      @repo.require feature
    end

    # An Array of sources for searching and installation.

    def sources
      source.sources
    end
  end
end
