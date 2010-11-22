module Gem

  # Wraps an Enumerable collection of Gem::Info or Gem::Specification
  # (or anything that quacks like them) and provides various bits of
  # sugar for filtering and searching. Gem::Source implementers may
  # want to subclass to provide more efficient behavior.
  #
  # Each filter is available in a mutating and a non-mutating
  # version. Non-mutating versions return a new Gem::Filter, which
  # shares its parent's wrapped collection.

  class Filter
    include Enumerable

    # The Enumerable wrapped by this filter.

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
      each { |e| grouped[e.send property] << e }
      grouped
    end

    # Iterate through filtered entries.

    def each &block
      wrapped.each do |e|
        next if latest? && !@latest.include?(e)
        next if prerelease? && !e.version.prerelease?
        next if released? && e.version.prerelease?

        block.call e
      end
    end

    # No matches?

    def empty?
      0 == count
    end

    # Return a new filter showing only the latest version of any entry.

    def latest
      duplicate { |c| c.latest! }
    end

    # Does this filter only allow the latest version of any entry?

    def latest?
      !!@latest
    end

    # Update the filter to only show the latest version of any entry.

    def latest!
      grouped = Hash.new { |h, k| h[k] = [] }
      @wrapped.each { |e| grouped[e.name] << e }
      @latest = grouped.values.map { |v| v.max }

      nil
    end

    # Return a new filter showing only entries with prerelease versions.

    def prerelease
      duplicate { |c| c.prerelease! }
    end

    # Does this filter only allow entries with prerelease versions?

    def prerelease?
      @prerelease
    end

    # Update the filter to only show entries with prerelease versions.

    def prerelease!
      @prerelease = true
      nil
    end

    # Return a new filter showing only entries with released versions.

    def released
      duplicate { |c| c.released! }
    end

    # Does this filter only allow entries with released versions?

    def released?
      @released
    end

    # Update the filter to only show entries with released versions.

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
    # filter.

    def search pattern, *versions
      options    = Hash === versions.last ? versions.pop : {}
      pattern    = /#{pattern}/i unless Regexp === pattern
      dependency = Gem::Dependency.new pattern, *versions

      Gem::Filter.new select { |e|
        dependency.matches_spec?(e) &&
          options[:platform].nil? or options[:platform] == e.platform
      }
    end

    # Get the first entry that matches +name+ and +versions+. Takes an
    # options has like search.

    def get name, *versions
      search(/\A#{name}\Z/, *versions).first
    end

    # Return a new filter with duplicates removed.

    def unique
      duplicate wrapped.uniq
    end

    alias_method :uniq, :unique

    # Replaces the wrapped collection with a copy where duplicates
    # have been removed.

    def unique!
      @wrapped = @wrapped.uniq
      self
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
        a << e.platform unless "ruby" == e.platform
        a.join "-"
      end

      names = names.join ", "

      arr = [self.class.name, features, names].reject { |e| e.empty? }
      "#<#{arr.join ': '}>"
    end
  end
end
