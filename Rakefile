require "rake/testtask"

task :default => :test

desc "Run the tests."
task :test do
  tests = ENV["ONLY"] ? [ENV["ONLY"]] : Dir["test/test_*.rb"]
  flags = %w(-w -Ilib:. -I../rubygems/lib)

  flags.unshift "--disable-gems" if RUBY_VERSION > "1.9"

  ruby = File.join RbConfig::CONFIG["bindir"],
  RbConfig::CONFIG["ruby_install_name"]

  ruby << RbConfig::CONFIG["EXEEXT"]

  requires = tests.map { |t| %Q(require "#{t}") }.join "; "
  sh "#{ruby} #{flags.join ' '} -e '#{requires}'"
end

desc "Test with SimpleCov."
task "test:coverage" do
  ENV["COVERAGE"] = "true"
  Rake::Task[:test].invoke
end
