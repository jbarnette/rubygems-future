require "rubygems/cli/filtered"

module Gem
  module CLI
    class List < Gem::CLI::Filtered
      def self.active?
        true
      end

      def self.args
        %w([pattern])
      end

      def self.description
        "List gems in the repo."
      end

      def self.verbs
        %w(list ls)
      end

      def run runtime, args
        results = narrow(runtime.repo.gems).search args.shift, *requirements

        versioned results do |name, versions|
          puts "#{name} (#{versions.join ', '})"
        end
      end
    end
  end
end
