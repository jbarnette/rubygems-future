module Gem
  class Globber
    def initialize repo
      @repo = repo
    end

    def spec path
      @repo.specs.detect do |spec|
        return unless libglob = libglob(spec)
        glob = File.join libglob, "#{path}#{Gem.suffix_pattern}"
        !Dir[glob].select { |f| File.file? f.untaint }.empty?
      end
    end

    # :stopdoc:

    def libglob spec
      return unless spec.require_paths

      gems = File.expand_path "../../gems", spec.loaded_from
      glob = "#{gems}/#{spec.full_name}/{#{spec.require_paths.join ','}}"

      (@libs ||= {})[spec.object_id] ||= glob # cache
    end
  end
end
