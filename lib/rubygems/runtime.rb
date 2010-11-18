module Gem

  # Represents the entire RubyGems runtime. Coordinates between
  # sources and repos. Entry point for most commands. Knows how to
  # enable and disable itself for global (gem, require) use.

  class Runtime

    # The local repo this runtime manages.

    attr_accessor :repo

    # An Array of sources for searching and installation.

    attr_reader :sources

    def initialize repo
      @repo    = repo
      @sources = []
    end

    def gem name, *requirements
      @repo.activate name, *requirements
    end

    def require feature
      @repo.require feature
    end
  end
end
