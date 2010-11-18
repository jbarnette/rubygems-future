module Gem

  # Manages a load path. Wraps $LOAD_PATH by default.

  class LoadPath
    attr_reader :paths

    def initialize paths = $LOAD_PATH
      @paths = $LOAD_PATH
    end

    # Add a set of +requires+ to the path. Respects -I,
    # ENV["RUBYLIB"], etc.

    def add *requires

      # Must insert in the correct place. Activated gems should come
      # after -I and ENV["RUBYLIB"]. If we can't determine the proper
      # place to insert them, just tack 'em on the end.

      index = paths.index(Gem::ConfigMap[:sitelibdir]) || -1

      paths.each_with_index do |path, i|
        if path.instance_variables.include?(:@gem_prelude_index) or
            path.instance_variables.include?('@gem_prelude_index') then
          index = i
          break
        end
      end

      paths.insert index, *requires
    end
  end
end
