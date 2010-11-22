require "rubygems/cli/command"
require "rubygems/requirement"

module Gem
  module CLI
    class Filtered < Gem::CLI::Command

      # Any version requirements specified on the command line.

      attr_reader :requirements

      def initialize opts
        super opts

        @all          = false
        @prereleases  = false
        @releases     = false
        @requirements = []

        opts.on "--all", "Any gem." do
          @all = true
        end

        opts.on "--released", "Only released gems." do
          @releases =true
        end

        opts.on "--pre", "--prerelease", "Only prerelease gems." do
          @prereleases = true
        end

        opts.on "--version REQ", "-v",
          "Version requirement. Multiple OK." do |req|

          @requirements << Gem::Requirement.create(req)
        end
      end

      # Show all matches?

      def all?
        @all
      end

      # Apply filters to +collection+ in-place.

      def narrow collection
        collection.latest!     unless all?
        collection.released!   if releases?
        collection.prerelease! if prereleases?
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
