require "fileutils"
require "rubygems/info"
require "rubygems/installable"
require "rubygems/installer"

module Gem
  module Installable

    # Implements the Gem::Installable protocol for <tt>.gem</tt> files
    # on disk.

    class File
      include Gem::Installable

      # Where does the source <tt>.gem</tt> file live?

      attr_reader :path

      def initialize path
        @path = ::File.expand_path path
      end

      def install repo
        si = Object.new
        def si.method_missing *; end

        options = {
          :bin_dir             => ::File.join(repo.home, "bin"),
          :env_shebang         => false,
          :force               => false,
          :ignore_dependencies => true,
          :install_dir         => repo.home,
          :source_index        => si,
        }

        Gem::Installer.new(path, options).install
        repo.reset
      end

      def gem
        @gem ||= Gem::Info.load path
      end
    end
  end
end
