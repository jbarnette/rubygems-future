module Gem
  class Globber
    def initialize repo
      @repo = repo
    end

    def spec path
      @repo.specs.detect do |spec|
        libglob = libglob spec
        return unless libglob

        glob = File.join libglob, "#{path}#{Gem.suffix_pattern}"
        !Dir[glob].select { |f| File.file? f.untaint }.empty?
      end
    end

    # :stopdoc:

    def libglob spec
      return unless spec.require_paths

      # Can't just do the path against the repo, since it might be
      # under something other than home.
      
      gems = File.expand_path "../../gems", spec.loaded_from
      "#{gems}/#{spec.full_name}/{#{spec.require_paths.join ','}}"
    end
  end
end
