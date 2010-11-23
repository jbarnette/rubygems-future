module Gem
  module CLI

    # Base class for <tt>bin/jim</tt> commands. In order for a command
    # to show up in the CLI it must live under the <tt>Gem::CLI</tt>
    # module, implement the static and instance methods exposed by
    # this class, and return +true+ when <tt>Klass.active?</tt> is
    # called. Inheriting from this class is probably the easiest way.

    class Command

      # Where do gems get instaled? What's the primary search path?
      # Defaults to <tt>"tmp/repo"</tt>.

      attr_reader :home

      # An Array of additional paths consulted when working with local
      # gems.

      attr_reader :paths

      # An Array of URLs for gem sources.

      attr_reader :sources

      # Should this class be exposed in the CLI? Default is +false+.

      def self.active?
        false
      end

      # For help: What args does this command take? Array of Strings,
      # defaults to empty.

      def self.args
        []
      end

      # A short description of this command. Defaults to <tt>"No
      # description."</tt>

      def self.description
        "No description."
      end

      # A help-friendly combination of +verbs+ and +args+.

      def self.syntax
        "#{verbs.join ', '} #{args.join ' '}"
      end

      # All the valid names for this command. Defaults to a downcased
      # version of the class name.

      def self.verbs
        [name.downcase.split("::").last]
      end

      # Create a new command instance. +opts+ is an optparse handler,
      # intended to be used to add command-specific options.

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
          "Repo home. Default is #@home." do |r|

          @home = r
        end

        opts.on "--path PATH", "-p",
          "Extra repo path. Multiple OK." do |p|

          @paths << p
        end

        opts.on "--quiet", "-q", "Silence!" do
          @quiet = true
        end

        opts.on "--source URL", "-s", "Source URL. Multiple OK." do |s|
          @sources << s
        end

        opts.on "--verbose", "-V", "Be chatty." do
          @verbose = true
        end
      end

      # Should we stop talking completely?

      def quiet?
        @quiet
      end

      # Should we talk too much?

      def verbose?
        @verbose
      end

      # Run the command.

      def run runtime, args
        abort "The #{self.class.verbs.join ', '} command isn't implemented."
      end
    end
  end
end
