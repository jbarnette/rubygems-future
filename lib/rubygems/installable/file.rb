require "rubygems/installer"
require "rubygems/package"

module Gem
  module Installable

    # Implements the Gem::Installable protocol for <tt>.gem</tt> files
    # on disk.

    class File
      include Gem::Installable

      # Where does the <tt>.gem</tt> file live?

      attr_reader :path

      def initialize path
        @path = ::File.expand_path path
      end

      def install repo

        # FIX: refactor Gem::Installer.

        source_index = Object.new
        def source_index.method_missing *; end

        options = {
          :bin_dir             => File.join(repo.home, "bin"),
          :env_shebang         => false,
          :force               => false,
          :ignore_dependencies => true,
          :install_dir         => repo.home,
          :source_index        => source_index,
        }

        Gem::Installer.new(spec.loaded_from, options).install
        repo.reset
      end

      def spec
        @spec ||= ::File.open path, "rb" do |f|
          Gem::Package.open f, "r" do |package|
            package.metadata
          end
        end
      end
    end
  end
end
