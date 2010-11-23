require "rubygems/collection"
require "rubygems/info"

require "uri"

module Gem

  # A protocol included by anything that can act as a source. Sources
  # are searchable collections of gems, able to provide an installable
  # representation of a gem when requested.
  #
  # The only methods that must be implemented on the including class
  # are +specs+ and +pull+. You'll probably want to do more than that
  # for efficiency, though.

  module Source

    # Searches constants under the <tt>Gem::Source</tt> module for a
    # class that is willing to handle +url+. If a handler class is
    # found, a new instance of it is returned.

    def self.for url
      url = URI.parse(url) unless URI === url
 
      klass = constants.map { |c| const_get c }.
        select { |c| c < Gem::Source }.
        detect { |c| c.respond_to?(:accepts?) && c.accepts?(url) }

      raise Gem::Exception,
        "Can't find a source to handle [#{url.to_s}]." unless klass

      klass.new url
    end

    def available? name, *requirements
      !specs.search(name, *requirements).empty?
    end

    # A pretty string representing this source. A URL or path is a
    # good bet.

    def display
      "unknown"
    end

    # Return a collection of Gem::Info\s, a lightweight equivalent to
    # Gem::Specification. See Gem::Collection for examples of how this
    # collection is searchable. Classes following the Gem::Source
    # protocol must implement this method.

    def gems
      @gems ||= Gem::Collection.new specs.wrapped.map { |s|
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
      @gems = nil # FIX
    end
  end
end
