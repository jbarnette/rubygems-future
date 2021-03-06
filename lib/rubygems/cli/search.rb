require "rubygems/cli/filtered"

module Gem
  module CLI
    class Search < Gem::CLI::Filtered
      def self.active?
        true
      end

      def self.args
        %w([pattern])
      end

      def self.description
        "Search remote sources."
      end

      def self.verbs
        %w(search)
      end

      def initialize opts
        super opts

        @show_sources = false

        opts.on "--show-sources", "Group results by source." do
          @show_sources = true
        end
      end

      def run runtime, args
        results = narrow(runtime.source.gems).search args.shift

        if show_sources?
          results.by(:source).each do |source, gems|
            puts "[#{source.display}]\n\n"
            show gems, "    "
            puts
          end
        else
          show results.uniq!
        end
      end

      def show_sources?
        @show_sources
      end

      def show gems, margin = nil
        versioned gems do |name, versions|
          puts "#{margin}#{name} (#{versions.join ', '})"
        end
      end
    end
  end
end
