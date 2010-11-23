require "rubygems/not_found"
require "rubygems/source"

module Gem
  module Source

    # Follows the <tt>Gem::Source</tt> protocol, combining results
    # from multiple sources.

    class Collection
      include Gem::Source

      attr_reader :sources

      def initialize *sources
        @sources = sources.flatten
      end

      def display
        sources.map { |s| s.display }.join ", "
      end

      def gems
        Gem::Collection.new sources.map { |s|s.gems.wrapped }.flatten
      end

      def pull name, *requirements
        source = sources.detect { |s| s.available? name, *requirements }
        raise Gem::NotFound.new(name, *requirements) unless source

        source.pull name, *requirements
      end

      def reset
        sources.each { |s| s.reset }
      end

      # :stopdoc:

      def to_s
        "#<#{self.class.name}: [#{sources.map { |s| s.display }.join ', '}]>"
      end
    end
  end
end
