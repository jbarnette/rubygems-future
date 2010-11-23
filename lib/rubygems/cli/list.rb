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
        results = narrow(runtime.repo.gems).
          search(args.shift, *requirements).by(:name)

        results.keys.sort_by(&:downcase).each do |name|
          versions = results[name].map(&:version)
          puts "#{name} (#{versions.join ', '})"
        end
      end
    end
  end
end
