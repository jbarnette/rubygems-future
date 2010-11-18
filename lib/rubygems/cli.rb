Dir["#{File.dirname(__FILE__)}/cli/*.rb"].each { |f|
  %r|(rubygems/cli/.*)\.rb$| =~ f
  require $1
}
