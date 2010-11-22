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

      def infos
        Gem::Filter.new sources.map { |s| s.infos.wrapped }.flatten
      end

      def pull name, *requirements
        source = sources.detect { |s| s.available? name, *requirements }
        raise Gem::NotFound.new(name, *requirements) unless source

        source.pull name, *requirements
      end

      def reset
        sources.each { |s| s.reset }
      end

      def specs
        Gem::Filter.new sources.map { |s| s.specs.wrapped }.flatten
      end

      # :stopdoc:

      def to_s
        "#<#{self.class.name}: [#{sources.map { |s| s.display }.join ', '}]>"
      end
    end
  end
end
