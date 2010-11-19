require "rubygems/collection"
require "rubygems/info"
require "rubygems/source/fs"

require "uri"

module Gem

  # This module represents the interface for anything that can act as
  # a source. Sources are searchable collections of gems that can
  # provide an installable representation of a gem when requested.
  #
  # The API is reasonably minimal, and the only methods that must be
  # implemented on the including class are +specs+ and +pull+. You'll
  # probably want to do more than that for efficiency, though.

  module Source

    def self.for url
      url = URI.parse(url) unless URI === url
 
      klass = constants.map { |c| const_get c }.
        select { |c| c < Gem::Source }.
        detect { |c| c.respond_to?(:accepts?) && c.accepts?(url) }

      raise Gem::Exception,
        "Can't find a source to handle [#{url.to_s}]." unless klass

      klass.new url
    end

    # A pretty string representing this source. A URL is a good bet.

    def display
      "unknown"
    end

    # Return a collection of Gem::Info\s, a lightweight equivalent to
    # Gem::Specification. See Gem::Collection for examples of how this
    # collection is searchable. The default implementation of this
    # method uses +specs+ to populate.

    def infos
      @infos ||= Gem::Collection.new specs.map { |s|
        Gem::Info.for s, self
      }
    end

    # Return an instance of Gem::Installable for the gem matching
    # +name+ and +version+. Installables know how to install and
    # update themselves in a repo.

    def pull name, version
      fail
    end

    # Make this source reload next time it's accessed.

    def reset
    end
  end
end