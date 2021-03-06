require 'mocha/integration/mini_test/assertion_counter'
require 'mocha/expectation_error'

module Mocha
  
  module Integration
    
    module MiniTest
      
      module Version142AndAbove
        def self.included(mod)
          $stderr.puts "Monkey patching MiniTest >= v1.4.2" if $options['debug']
        end
        def run runner
          trap 'INFO' do
            warn '%s#%s %.2fs' % [self.class, self.__name__,
              (Time.now - runner.start_time)]
            runner.status $stderr
          end if ::MiniTest::Unit::TestCase::SUPPORTS_INFO_SIGNAL
          
          assertion_counter = AssertionCounter.new(self)
          result = '.'
          begin
            begin
              @passed = nil
              self.setup
              self.__send__ self.__name__
              mocha_verify(assertion_counter)
              @passed = true
            rescue *::MiniTest::Unit::TestCase::PASSTHROUGH_EXCEPTIONS
              raise
            rescue Exception => e
              @passed = false
              result = runner.puke(self.class, self.__name__, Mocha::Integration::MiniTest.translate(e))
            ensure
              begin
                self.teardown
              rescue *PASSTHROUGH_EXCEPTIONS
                raise
              rescue Exception => e
                result = runner.puke(self.class, self.__name__, Mocha::Integration::MiniTest.translate(e))
              end
              trap 'INFO', 'DEFAULT' if ::MiniTest::Unit::TestCase::SUPPORTS_INFO_SIGNAL
            end
          ensure
            mocha_teardown
          end
          result
        end
      end
      
    end
    
  end
  
end
