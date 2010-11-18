require "rake/testtask"
require "rubygems/defaults"

task :default do
  tests = Dir["test/test_*.rb"]
  flags = %w(-w -Ilib:. -I../rubygems/lib)

  flags.unshift "--disable-gems" if RUBY_VERSION > "1.9"

  ruby = File.join RbConfig::CONFIG["bindir"],
  RbConfig::CONFIG["ruby_install_name"]

  ruby << RbConfig::CONFIG["EXEEXT"]

  requires = tests.map { |t| %Q(require "#{t}") }.join "; "
  sh "#{ruby} #{flags.join ' '} -e '#{requires}'"
end
