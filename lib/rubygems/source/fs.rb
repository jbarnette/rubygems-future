require "rubygems/installable"
require "rubygems/package"

module Gem
  module Source
    class FS
      include Gem::Source

      attr_reader :display

      # Path to the .gem file or directory for this source.

      attr_reader :path

      def self.accepts? url
        "file" == url.scheme
      end

      def initialize url
        @display  = url.to_s
        @path     = File.expand_path url.path
      end

      # An Array of paths to .gem files in this source.

      def files
        return @files if defined? @files

        files = []

        if File.file? path
          unless /\.gem/i =~ path
            raise Gem::Exception, "#{path} isn't a .gem file."
          end

          files << path
        else
          files.concat Dir[File.join path, "*.gem"]
        end

        @files = files
      end

      def pull name, version
        spec = specs.search(name, Gem::Version.create(version)).first
        raise Gem::Exception, "Can't find  #{name}-#{version}." unless spec
        Gem::Installable::File.new File.join(path, spec.file_name)
      end

      def reset
        @files = nil
        @specs = nil
      end

      def specs
        return @specs if defined? @specs

        specs = files.map do |file|
          File.open file, "rb" do |f|
            Gem::Package.open f, "r" do |package|
              package.metadata
            end
          end
        end

        @specs ||= Gem::Collection.new specs
      end
    end
  end
end
