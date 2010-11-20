require "rubygems/source"

module Gem
  module Source

    # Follows the <tt>Gem::Source</tt> protocol, combining results
    # from multiple sources.

    class Multi
      include Gem::Source

      attr_reader :sources

      def initialize *sources
        @sources = sources.flatten
      end

      def display
        sources.map { |s| s.display }.join ", "
      end

      def infos
        sources.map { |s| s.infos }.uniq
      end

      def pull name, version
        info = infos.search(name, Gem::Version.create(version)).first

        unless info
          raise Gem::Exception, "Can't find  #{info.display} in any source."
        end

        info.source.pull name, version
      end

      def reset
        sources.each { |s| s.reset }
      end

      def specs
        sources.map { |s| s.specs }.uniq
      end
    end
  end
end
