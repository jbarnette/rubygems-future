# Some stubs to keep from having to do the real 'require
# "rubygems"'. It comes with too much cruft. Many other RG files don't
# do well with this. This does a really good job of showing what
# methods should be moved off of the Gem module too.

module Gem
  VERSION         = "1.3.7" unless defined? ::Gem::VERSION # tons
  ConfigMap       = {} unless defined? ::Gem::ConfigMap # tons
  RubyGemsVersion = VERSION unless defined? ::Gem::RubyGemsVersion # jruby
  UserInteraction = Module.new # security

  def self.binary_mode # installer
    "rb"
  end

  def self.configuration # builder
    require "ostruct"
    OpenStruct.new
  end

  def self.dir # installer
    nil
  end

  def self.ensure_gem_subdirectories _ # installer
  end

  def self.post_install_hooks # installer
    []
  end

  def self.pre_install_hooks # installer
    []
  end

  def self.ruby_version # installer
    Gem::Version.new "42"
  end

  def self.source_index # installer
    nil
  end

  def self.suffix_pattern
    @suffix_pattern ||= "{#{suffixes.join(',')}}"
  end

  def self.suffixes # activation, require
    ['', '.rb', '.rbw', '.so', '.bundle', '.dll', '.sl', '.jar']
  end

  def self.user_home # security
    ENV["HOME"]
  end
end
