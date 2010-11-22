require "rubygems/collection"
require "rubygems/installable"
require "rubygems/package"
require "uri"

module Gem
  module Source

    # A source for .gem files on disk. Knows how to deal with being
    # pointed at a single .gem file, a directory of gems, or a repo
    # with "specifications" and "cache" directories.

    class Local
      include Gem::Source

      # A display string for this source. The URL or path.

      attr_reader :display

      # An Array of the .gem files the source knows about.

      attr_reader :files

      # Path to the .gem file or directory for this source.

      attr_reader :path

      # A collection of Gem::Specification\s for this source.

      attr_reader :specs

      def self.accepts? url
        !url.scheme || "file" == url.scheme.downcase
      end

      def initialize url
        url = URI.parse(url) unless URI === url

        @display  = url.to_s
        @path = File.expand_path url.path

        reset
      end

      def pull name, *requirements
        spec = specs.get name, *requirements
        raise Gem::NotFound.new(name, version) unless spec

        gem  = spec.file_name
        file = files.detect {|f| gem == File.basename(f) }

        Gem::Installable::File.new file
      end

      def reset
        files = nil
        specs = nil

        if File.file? path
          unless /\.gem/i =~ path
            raise Gem::Exception, "#{path} isn't a .gem file."
          end

          # The source is pointed at a single .gem file.

          specs = [spec_from_gem_file(path)]
          files = [path]

        elsif File.directory?("#{path}/specifications")

          # The source is pointed at a repo directory. Make all
          # gemspecs in the "specifications" directory available by
          # using .gem files in the "cache" directory.

          specs = Dir["#{path}/specifications/*.gemspec"].map do |file|
            Gem::Specification.load file
          end

          files = specs.map { |spec| "#{path}/cache/#{spec.file_name}" }
        else

          # The source is pointed at a bare directory of .gem files.

          files = Dir["#{path}/*.gem"]
          specs = files.map { |f| spec_from_gem_file f }
        end

        @files = files
        @specs = Gem::Collection.new specs

        super
      end

      # :stopdoc:

      def spec_from_gem_file file
        File.open file, "rb" do |f|
          Gem::Package.open f, "r" do |package|
            package.metadata
          end
        end
      end

      def to_s
        "#<#{self.class.name}: #{path}>"
      end
    end
  end
end
