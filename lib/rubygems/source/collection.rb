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
        infos = sources.map { |s| s.infos.entries }.flatten
        infos.uniq!

        Gem::Collection.new infos
      end

      def pull name, version
        source = sources.detect { |s| s.available? name, version }

        unless source
          raise Gem::Exception,
            "Can't find #{name}-#{version} in any source."
        end

        source.pull name, version
      end

      def reset
        sources.each { |s| s.reset }
      end

      def specs
        specs = sources.map { |s| s.specs.entries }.flatten
        specs.uniq!

        Gem::Collection.new specs
      end
 
      # :stopdoc:
      
      def to_s
        "#<#{self.class.name}: [#{sources.map { |s| s.display }.join ', '}]>"
      end
    end
  end
end
