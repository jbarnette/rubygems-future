require "rubygems/dependency"

module Gem

  # Represents a searchable collection of specifications or infos
  # (or anything that respons to +name+, +platform+, and +version+,
  # really). This default implementation uses an Array as a backing
  # store, but Gem::Source implementers may subclass it to provide
  # more time and space efficient behavior.

  class Collection
    include Enumerable

    attr_reader :entries

    # Create a new instance with an optional Array of +entries+.

    def initialize entries = nil
      @entries = (entries || []).sort_by { |e| [e.name, e.version] }.reverse!
    end

    # Return a Hash containing the entries in this collection grouped
    # by a property.

    def by property
      @grouped ||=
        (grouped = Hash.new { |h,k| h[k] = [] }
         each { |e| grouped[e.send property] << e }
         grouped.each { |k, v| grouped[k] = self.class.new v }
         grouped)
    end

    # Iterate through all entries. Instances of this class are
    # Enumerable.

    def each &block
      @entries.each(&block)
    end

    # Is this collection empty?

    def empty?
      @entries.empty?
    end

    # The first entry in the collection.

    def first
      each { |e| break e }
    end

    # Return a collection containing only the latest entries. Depends
    # on entries being presorted.

    def latest
      latest = Hash.new { |h, k| h[k] = [] }
      @entries.each { |e| latest[e.name] << e }

      self.class.new latest.values.map { |a| a.first }.
        sort_by { |e| e.version }
    end

    # Return a collection containing only prerelease entries.

    def prerelease
      @prerelease ||= self.class.new @entries.select { |e|
        e.version.prerelease?
      }
    end

    # Return a collection containing only released entries.

    def released
      @released ||= self.class.new @entries.reject { |e|
        e.version.prerelease?
      }
    end

    # Search this collection for entries matching +name+ and
    # +requirements+. The last entry in +requirements+ may be a
    # Hash. If the Hash contains a <tt>:platform</tt> key, only
    # entries matching the specified platform will be returned.

    def search name, *requirements
      options    = Hash === requirements.last ? requirements.pop : {}
      dependency = Gem::Dependency.new(/#{name}/, *requirements)

      self.class.new @entries.select { |e|
        dependency.matches_spec?(e) &&
          (!options[:platform] || options[:platform] == e.platform )
      }
    end

    # :nodoc:

    def == other
      self.class === other && entries == other.entries
    end

    def size
      @entries.size
    end

    alias_method :length, :size
    alias_method :count,  :size

    def to_s
      "#<#{self.class.name}: #{@entries.inspect}>"
    end

    def uniq
      self.class.new @entries.uniq
    end

    def uniq!
      @entries.uniq!
      self
    end
  end
end
