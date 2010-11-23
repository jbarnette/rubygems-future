require "rubygems/collection"
require "rubygems/installable"
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

      # A collection of Gem::Info\s for this source.

      attr_reader :gems

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
        gem = gems.get name, *requirements
        raise Gem::NotFound.new(name, version) unless gem

        file = files.detect {|f| "#{gem.id}.gem" == File.basename(f) }
        Gem::Installable::File.new file
      end

      def reset
        files = nil
        gems  = nil

        if File.file? path
          unless /\.gem/i =~ path
            raise Gem::Exception, "#{path} isn't a .gem file."
          end

          # The source is pointed at a single .gem file.

          gems  = [Gem::Info.load(path)]
          files = [path]

        elsif File.directory?("#{path}/specifications")

          # The source is pointed at a repo directory. Make all
          # gemspecs in the "specifications" directory available by
          # using .gem files in the "cache" directory.

          gems = Dir["#{path}/specifications/*.gemspec"].map do |file|
            Gem::Info.for Gem::Specification.load(file), self
          end

          files = gems.map { |g| "#{path}/cache/#{g.id}.gem" }
        else

          # The source is pointed at a bare directory of .gem files.

          files = Dir["#{path}/*.gem"]
          gems  = files.map { |f| Gem::Info.load f }
        end

        @files = files
        @gems  = Gem::Collection.new gems

        super
      end

      # :stopdoc:

      def to_s
        "#<#{self.class.name}: #{path}>"
      end
    end
  end
end
