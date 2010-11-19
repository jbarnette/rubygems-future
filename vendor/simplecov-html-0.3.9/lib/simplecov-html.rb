require 'erb'
require 'cgi'
require 'fileutils'
require 'digest/sha1'
require 'time'

unless defined?(SimpleCov)
  raise RuntimeError, "simplecov-html is now the default formatter of simplecov. Please update your test helper and gemfile to require 'simplecov' instead of 'simplecov-html'!"
end
# Ensure we are using an compatible version of SimpleCov
if Gem::Version.new(SimpleCov::VERSION) < Gem::Version.new("0.3.2")
  raise RuntimeError, "The version of SimpleCov you are using is too old. Please update with 'gem install simplecov'"
end

class SimpleCov::Formatter::HTMLFormatter
  VERSION = File.read(File.join(File.dirname(__FILE__), '../VERSION')).strip.chomp
  
  def format(result)
    Dir[File.join(File.dirname(__FILE__), '../assets/*')].each do |path|
      FileUtils.cp_r(path, asset_output_path)
    end
    
    File.open(File.join(output_path, "index.html"), "w+") do |file|
      file.puts template('layout').result(binding)
    end
    puts "Coverage report generated for #{result.command_name} to #{output_path}"
  end
  
  private
  
  # Returns the an erb instance for the template of given name
  def template(name)
    ERB.new(File.read(File.join(File.dirname(__FILE__), '../views/', "#{name}.erb")))
  end
  
  def output_path
    SimpleCov.coverage_path
  end
  
  def asset_output_path
    return @asset_output_path if @asset_output_path
    @asset_output_path = File.join(output_path, 'assets', SimpleCov::Formatter::HTMLFormatter::VERSION)
    FileUtils.mkdir_p(@asset_output_path)
    @asset_output_path
  end
  
  def assets_path(name)
    File.join('./assets', SimpleCov::Formatter::HTMLFormatter::VERSION, name)
  end
  
  # Returns the html for the given source_file
  def formatted_source_file(source_file)
    template('source_file').result(binding)
  end
  
  # Returns a table containing the given source files
  def formatted_file_list(title, source_files)
    template('file_list').result(binding)
  end
  
  # Computes the coverage based upon lines covered and lines missed
  def coverage(file_list)
    return 100.0 if file_list.length == 0 or lines_of_code(file_list) == 0
    lines_missed = file_list.map {|f| f.missed_lines.count }.inject(&:+)
    
    lines_covered(file_list) * 100 / lines_of_code(file_list).to_f
  end
  
  def lines_of_code(file_list)
    lines_missed(file_list) + lines_covered(file_list)
  end
  
  def lines_covered(file_list)
    return 0.0 if file_list.length == 0
    file_list.map {|f| f.covered_lines.count }.inject(&:+)
  end
  
  def lines_missed(file_list)
    return 0.0 if file_list.length == 0
    file_list.map {|f| f.missed_lines.count }.inject(&:+)
  end
  
  def coverage_css_class(covered_percent)
    if covered_percent > 90
      'green'
    elsif covered_percent > 80
      'yellow'
    else
      'red'
    end
  end
  
  # Return a (kind of) unique id for the source file given. Uses SHA1 on path for the id
  def id(source_file)
    Digest::SHA1.hexdigest(source_file.filename)
  end
  
  def timeago(time)
    "<abbr class=\"timeago\" title=\"#{time.iso8601}\">#{time.iso8601}</abbr>"
  end
  
  def shortened_filename(source_file)
    source_file.filename.gsub(SimpleCov.root, '.')
  end
  
  def link_to_source_file(source_file)
    %Q(<a href="##{id source_file}" class="src_link" title="#{shortened_filename source_file}">#{shortened_filename source_file}</a>)
  end
end