# Some stubs to keep from having to do the real 'require
# "rubygems"'. It comes with too much cruft. Many other RG files don't
# do well with this.

module Gem
  VERSION         = "1.3.7" unless defined? ::Gem::VERSION # tons
  ConfigMap       = {} unless defined? ::Gem::ConfigMap # tons
  RubyGemsVersion = VERSION unless defined? ::Gem::RubyGemsVersion # jruby
  UserInteraction = Module.new # security

  def self.user_home # security
    ENV["HOME"]
  end

  def self.suffix_pattern
    @suffix_pattern ||= "{#{suffixes.join(',')}}"
  end

  def self.suffixes
    ['', '.rb', '.rbw', '.so', '.bundle', '.dll', '.sl', '.jar']
  end
end
