require "rubygems/cli/filtered"

module Gem
  module CLI
    class Install < Gem::CLI::Filtered
      def self.active?
        true
      end

      def initialize opts
        super opts

        @force = false

        opts.on "--force", "-f", "Overwrite if already installed." do
          @force = true
        end
      end

      def self.args
        %w(GEM)
      end

      def self.description
        "Install a gem."
      end

      def self.verbs
        %w(install)
      end

      def force?
        @force
      end

      def run runtime, args
        p args
      end
    end
  end
end
