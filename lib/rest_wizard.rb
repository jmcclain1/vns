# Finally a wizard approach to REST!

module RestWizard
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def wizard(name, options)
      wizard_options_name = "@@#{name}_options".to_sym
      class_variable_set(wizard_options_name, [name, options[:steps]])

      define_method name do
        Wizard.new(self.class.send(:class_variable_get, wizard_options_name)[0], self.class.send(:class_variable_get, wizard_options_name)[1], params, self)
      end
    end
  end

  class Wizard
    def initialize(name, steps, params, controller)
      @name = name
      @steps = steps
      @params = params
      @controller = controller
    end

    def active?
      @params[@name] != nil
    end

    def current_step_name
      @params[@name][:step]
    end

    def current_step_number
      @steps.index(@steps.select {|key, value| value[:name] == current_step_name}.first[1])
    end

    def current_step_template
      @steps.select {|key, value| value[:name] == current_step_name}.first[1][:template]
    end
  end
end

ActionController::Base.send :include, RestWizard