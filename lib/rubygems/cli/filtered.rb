require "rubygems/cli/command"

module Gem
  module CLI
    class Filtered < Gem::CLI::Command
      def initialize opts
        super opts

        @all         = false
        @prereleases = false
        @releases    = false

        opts.on "--all", "Any gem." do
          @all = true
        end

        opts.on "--released", "Only released gems." do
          @releases =true
        end

        opts.on "--pre", "--prerelease", "Only prerelease gems." do
          @prereleases = true
        end
      end

      # Show all matches?

      def all?
        @all
      end

      # Filter +collection+ based on the options set. Releases and
      # prereleases are obviously mutually exclusive.

      def filter collection
        collection = collection.latest     unless all?
        collection = collection.released   if releases?
        collection = collection.prerelease if prereleases?
        collection
      end

      # Show only prerelease matches?

      def prereleases?
        @prereleases
      end

      # Show only released matches?

      def releases?
        @releases
      end
    end
  end
end
