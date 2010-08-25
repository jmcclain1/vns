
# for backward compatibility with previous versions of RSPEC
module Spec
  module Rails
    module Runner
      class EvalContext < Test::Unit::TestCase
        def response_code_should_be(sym)
          case sym
          when :forbidden
            response.response_code.should == 403
          when :bad_request
            response.response_code.should == 400
          else
            raise "Only :forbidden and :bad_request currently supported by this helper. Extend it!"
          end
        end
      end
    end
  end
end

# for RSPEC 0.9
# icky code duplication will go away when  we've migrated off older versions of rspec
# tried to put the function into a module and mix it in, but it didn't work ...
# TODO: ESH/BT - remove duplication.
module Spec
  module Rails
    module DSL
      module AllBehaviourHelpers
        def response_code_should_be(sym)
          case sym
          when :forbidden
            response.response_code.should == 403
          when :bad_request
            response.response_code.should == 400
          else
            raise "Only :forbidden and :bad_request currently supported by this helper. Extend it!"
          end
        end
      end
    end
  end
end
