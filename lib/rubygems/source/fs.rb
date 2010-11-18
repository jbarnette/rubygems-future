require "rubygems/package"

module Gem
  module Source
    class FS
      include Gem::Source

      attr_reader :display

      # An Array of paths to .gem files in this source.

      attr_reader :files

      # Path to the .gem file or directory for this source.

      attr_reader :path

      def self.accepts? url
        "file" == url.scheme
      end

      def initialize url
        @display  = url.to_s
        @files    = []
        @path     = File.expand_path url.path

        if File.file? path
          raise "#{path} isn't a .gem file." unless /\.gem/i =~ path
          files << path
        else
          files.concat Dir["#{path}/*.gem"]
        end
      end

      def pull name, version
        spec = specs.search(name, version).first
        raise "I don't have a spec for #{name}-#{version}." unless spec
        Gem::Installable.new spec
      end

      def specs
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
