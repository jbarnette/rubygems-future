require "rubygems/exceptions"

module Gem
  class NotFound < Gem::Exception
    def initialize name, *requirements
      req = Gem::Requirement.create requirements
      req = requirements.empty? ? "" : " (#{req.as_list.join ', '})"
      super "Can't find #{name}#{req}."
    end
  end
end
