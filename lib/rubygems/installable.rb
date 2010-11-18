require "rubygems/installer"

module Gem
  class Installable
    def initialize spec
      @spec = spec
    end

    # One could subclass and override this to, say, create and update
    # symlinks to a Git repo or something. FIX: Extract and refactor
    # Gem::Installer instead of using it.

    def install repo
      unless String === from && File.file?(from) && /\.gem$/i =~ from
        raise "The default impl. only knows how to deal with .gem files."
      end

      fake = Object.new
      def fake.method_missing *; end

      options = {
        :bin_dir             => File.join(repo.home, "bin"),
        :env_shebang         => false,
        :force               => false,
        :ignore_dependencies => true,
        :install_dir         => repo.home,
        :source_index        => fake,
      }

      Gem::Installer.new(spec.loaded_from, options).install
      repo.reset
    end
  end
end
