module Gem
  class Globber
    def initialize repo
      @repo = repo
    end

    def gem path
      @repo.gems.detect do |gem|
        libglob = libglob gem
        return unless libglob

        glob = File.join libglob, "#{path}#{Gem.suffix_pattern}"
        !Dir[glob].select { |f| File.file? f.untaint }.empty?
      end
    end

    # :stopdoc:

    # FIX: this is ridiculously fragile. Need to be able to ask the
    # Gem::Info or speficiation for this sort of thing.

    def libglob gem
      return unless gem.spec.require_paths

      # Can't just do the path against the repo, since it might be
      # under something other than home.

      gems = File.expand_path "../../gems", gem.spec.loaded_from
      File.join "{#{gems}}", gem.id, "{#{gem.spec.require_paths.join ','}}"
    end
  end
end
