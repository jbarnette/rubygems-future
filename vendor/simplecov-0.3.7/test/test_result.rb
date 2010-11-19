require 'helper'

class TestResult < Test::Unit::TestCase
  context "With a (mocked) Coverage.result" do
    setup do
      SimpleCov.filters = []
      SimpleCov.groups = {}
      SimpleCov.formatter = nil
      @original_result = {source_fixture('sample.rb') => [nil, 1, 1, 1, nil, nil, 1, 1, nil, nil],
          source_fixture('app/models/user.rb') => [nil, 1, 1, 1, nil, nil, 1, 0, nil, nil],
          source_fixture('app/controllers/sample_controller.rb') => [nil, 1, 1, 1, nil, nil, 1, 0, nil, nil]}
    end
  
    context "a simple cov result initialized from that" do
      setup { @result = SimpleCov::Result.new(@original_result) }
    
      should "have 3 filenames" do
        assert_equal 3, @result.filenames.count
      end
    
      should "have 3 source files" do
        assert_equal 3, @result.source_files.count
        assert @result.source_files.all? {|s| s.instance_of?(SimpleCov::SourceFile)}, "Not alL instances are of SimpleCov::SourceFile type"
      end
    
      should "have files equal to source_files" do
        assert_equal @result.files, @result.source_files
      end
      
      should "have accurate covered percent" do
        # in our fixture, there are 13 covered line (result in 1) in all 15 relevant line (result in non-nil)
        assert_equal 100.0*13/15, @result.covered_percent
      end
      
      context "dumped with to_yaml" do
        setup { @yaml = @result.to_yaml }
        should("be a string") { assert_equal String, @yaml.class }
        
        context "loaded back with from_yaml" do
          setup { @dumped_result = SimpleCov::Result.from_yaml(@yaml) }
          
          should "have 3 source files" do
            assert_equal @result.source_files.count, @dumped_result.source_files.count
          end
          
          should "have the same covered_percent" do
            assert_equal @result.covered_percent, @dumped_result.covered_percent
          end
          
          should "have the same created_at" do
            assert_equal @result.created_at, @dumped_result.created_at
          end
          
          should "have the same command_name" do
            assert_equal @result.command_name, @dumped_result.command_name
          end
          
          should "have the same original_result" do
            assert_equal @result.original_result, @dumped_result.original_result
          end
        end
      end
    end
    
    context "with some filters set up" do
      setup do
        SimpleCov.add_filter 'sample.rb'
      end
      
      should "have 2 files in a new simple cov result" do
        assert_equal 2, SimpleCov::Result.new(@original_result).source_files.length
      end
      
      should "have 80 covered percent" do
        assert_equal 80, SimpleCov::Result.new(@original_result).covered_percent
      end
    end
    
    context "with groups set up for all files" do
      setup do
        SimpleCov.add_group 'Models', 'app/models'
        SimpleCov.add_group 'Controllers', 'app/controllers'
        SimpleCov.add_group 'Other' do |src_file|
          File.basename(src_file.filename) == 'sample.rb'
        end
        @result = SimpleCov::Result.new(@original_result)
      end
      
      should "have 3 groups" do
        assert_equal 3, @result.groups.length
      end
      
      should "have user.rb in 'Models' group" do
        assert_equal 'user.rb', File.basename(@result.groups['Models'].first.filename)
      end
      
      should "have sample_controller.rb in 'Controllers' group" do
        assert_equal 'sample_controller.rb', File.basename(@result.groups['Controllers'].first.filename)
      end
      
      context "and simple formatter being used" do
        setup {SimpleCov.formatter = SimpleCov::Formatter::SimpleFormatter}
        
        should "return a formatted string with result.format!" do
          assert_equal String, @result.format!.class
        end
      end
    end
  
    context "with groups set up that do not match all files" do
      setup do
        SimpleCov.configure do
          add_group 'Models', 'app/models'
          add_group 'Controllers', 'app/controllers'
        end
        @result = SimpleCov::Result.new(@original_result)
      end
      
      should "have 3 groups" do
        assert_equal 3, @result.groups.length
      end
      
      should "have 1 item per group" do
        @result.groups.each do |name, files|
          assert_equal 1, files.length, "Group #{name} should have 1 file"
        end
      end

      should "have sample.rb in 'Ungrouped' group" do
        assert_equal 'sample.rb', File.basename(@result.groups['Ungrouped'].first.filename)
      end
    end
  end
end
