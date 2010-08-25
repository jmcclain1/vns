if Spec::VERSION::STRING == "0.9.4"
  class Spec::Rails::DSL::HelperBehaviour < Spec::DSL::Behaviour
    def before_eval #:nodoc:
      inherit Spec::Rails::DSL::HelperEvalContext
      prepend_before {setup}
      append_after {teardown}
      include described_type if described_type
      configure
    end
  end
end
