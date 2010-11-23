require "tsort"

module Gem

  # Wraps an Enumerable collection of Gem::Info or Gem::Specification
  # (or anything that quacks like them) and provides various bits of
  # sugar for filtering, searching, and ordering. Gem::Source
  # implementers may want to subclass to provide more efficient
  # behavior.
  #
  # Each filter is available in a mutating and a non-mutating
  # version. Non-mutating versions return a new Gem::Collection which
  # shares its parent's wrapped collection.

  class Collection
    include Enumerable
    include TSort

    # The Enumerable wrapped by this collection.

    attr_reader :wrapped

    def initialize wrapped, &block
      @latest     = nil
      @prerelease = false
      @released   = false
      @wrapped    = wrapped

      yield self if block_given?
    end

    # Group entries by +property+, returning a Hash of Array values.

    def by property
      grouped = Hash.new { |h, k| h[k] = [] }
      each { |e| grouped[e.send(property)] << e }
      grouped
    end

    # Iterate through filtered entries.

    def each &block
      wrapped.each do |e|
        next if latest? && !@latest.include?(e)
        next if prerelease? && !e.version.prerelease?
        next if released? && e.version.prerelease?

        block.call(e)
      end
    end

    # No matches?

    def empty?
      0 == size
    end

    # Return the first entry in the collection or +nil+ if empty.

    def first
      each { |e| return e }
      nil
    end

    # Get the first entry that matches +name+ and +versions+. Takes an
    # optional options Hash like search.

    def get name, *versions
      search(/\A#{name}\Z/, *versions).first
    end


    # Return a new collection exposing only the latest version of any entry.

    def latest
      duplicate { |c| c.latest! }
    end

    # Does this collection only expose the latest version of any
    # entry?

    def latest?
      !!@latest
    end

    # Update the collection to only expose the latest version of any
    # entry.

    def latest!
      grouped = Hash.new { |h, k| h[k] = [] }
      @wrapped.each { |e| grouped[e.name] << e }
      @latest = grouped.values.map { |v| v.max }

      nil
    end

    # Returns an Array containing the filtered entries in this
    # collection ordered by dependency, so that no entry depends on an
    # entry earlier in the list. This will not add entries for missing
    # dependencies: It only orders the entries in this
    # collection. Passing +development+ as +true+ will consult
    # development dependencies as well as runtime.

    def ordered development = false
      @development = development

      ordered = []
      seen    = {}

      strongly_connected_components.flatten.each do |entry|
        index = seen[entry.name]

        if index
          if ordered[index].version < entry.version
            ordered[index] = entry
          end
        else
          seen[entry.name] = ordered.length
          ordered << entry
        end
      end

      ordered
    end

    # Return a new collection exposing only entries with prerelease
    # versions.

    def prerelease
      duplicate { |c| c.prerelease! }
    end

    # Does this collection only expose entries with prerelease
    # versions?

    def prerelease?
      @prerelease
    end

    # Update the collection to only expose entries with prerelease
    # versions.

    def prerelease!
      @prerelease = true
      nil
    end

    # Return a new collection exposing only entries with released
    # versions.

    def released
      duplicate { |c| c.released! }
    end

    # Does this collection only expose entries with released versions?

    def released?
      @released
    end

    # Update the collection to only show entries with released versions.

    def released!
      @released = true
      nil
    end

    # Search for entries whose names matches a +pattern+ (which may be
    # a Regexp: If it's a string it's assumed to be a case
    # instensitive compare) with an optional set of +versions+,
    # expressed as strings or Gem::Requirement instances. The last
    # argument can be an optional Hash of +options+. The only
    # currently supported key is <tt>:platform</tt>. Returns a new
    # collection.

    def search pattern, *versions
      options    = Hash === versions.last ? versions.pop : {}
      pattern    = /#{pattern}/i unless Regexp === pattern
      dependency = Gem::Dependency.new pattern, *versions

      results = select do |e|
        dependency.matches_spec?(e) &&
          options[:platform].nil? or options[:platform] == e.platform
      end

      Gem::Collection.new results
    end

    def size
      inject(0) { |m, _| m + 1 }
    end

    # Return a new collection with duplicates removed.

    def unique
      duplicate wrapped.uniq
    end

    alias_method :uniq, :unique

    # Replaces the wrapped collection with a copy where duplicates
    # have been removed.

    def unique!
      @wrapped = @wrapped.uniq
      nil
    end

    alias_method :uniq!, :unique!

    # :stopdoc:

    def duplicate wrapped = @wrapped, &block
      self.class.new(wrapped) do |c|
        c.latest!     if latest?
        c.prerelease! if prerelease?
        c.released!   if released?

        block.call c if block_given?
      end
    end

    def == other
      self.class === other && wrapped == other.wrapped &&
        latest? == other.latest? && prerelease? == other.prerelease? &&
        released? == other.released?
    end

    def hash
      wrapped.hash
    end

    def to_s
      features = []
      features << :latest     if latest?
      features << :prerelease if prerelease?
      features << :released   if released?

      features = features.join ", "

      names = map do |e|
        a = [e.name, e.version]
        a << e.platform unless Gem::Platform::RUBY == e.platform
        a.join "-"
      end

      names = names.join ", "

      arr = [self.class.name, features, names].reject { |e| e.empty? }
      "#<#{arr.join ': '}>"
    end

    def tsort_each_child current, &block
      allowed  = [nil, :runtime]
      allowed << :development if @development

      deps = current.dependencies.select { |d| allowed.include? d.type }

      deps.each do |dep|
        target = detect { |e| dep.matches_spec? e }
        yield target if target
      end
    end

    alias_method :tsort_each_node, :each
  end
end
