module Gem
  module CLI
    class Command
      attr_reader :home
      attr_reader :paths
      attr_reader :sources

      def self.active?
        false
      end

      def self.args
        []
      end

      def self.description
        "No description."
      end

      def self.syntax
        "#{verbs.join ', '} #{args.join ' '}"
      end

      def self.verbs
        [name.downcase.split("::").last]
      end

      def initialize opts
        @home    = "tmp/repo"
        @paths   = []
        @quiet   = false
        @sources = []
        @verbose = false

        opts.on "--env", "-e", "Use GEM_HOME and GEM_PATH." do
          @home  = ENV["GEM_HOME"]
          @paths = ENV["GEM_PATH"].split File::PATH_SEPARATOR
        end

        opts.on "--home PATH", "-r",
          "Set repo home. Default is #@home." do |r|

          @home = r
        end

        opts.on "--path PATH", "-p",
          "Add extra repo path. Multiple OK." do |p|

          @paths << p
        end

        opts.on "--quiet", "-q", "STFU." do
          @quiet = true
        end

        opts.on "--source URL", "-s", "Adda source URL. Multiple OK." do |s|
          @sources << s
        end

        opts.on "--verbose", "-V", "Be chatty." do
          @verbose = true
        end
      end

      def quiet?
        @quiet
      end

      def verbose?
        @verbose
      end

      def run runtime, args
        abort "The #{self.class.verbs.join ', '} command isn't implemented."
      end
    end
  end
end
