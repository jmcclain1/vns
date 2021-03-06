begin
  require 'rubygems'
  require 'heckle'
rescue LoadError ; raise "You must gem install heckle to use --heckle" ; end

module Spec
  module Runner
    # Creates a new Heckler configured to heckle all methods in the classes
    # whose name matches +filter+
    class HeckleRunner
      def initialize(filter, heckle_class=Heckler)
        @filter = filter
        @heckle_class = heckle_class
      end
      
      # Runs all the contexts held by +behaviour_runner+ once for each of the 
      # methods in the matched classes.
      def heckle_with(behaviour_runner)
        if @filter =~ /(.*)[#\.](.*)/
          heckle_method($1, $2)
        else
          heckle_class_or_module(@filter)
        end
      end
      
      def heckle_method(class_name, method_name)
        verify_constant(class_name)
        heckle = @heckle_class.new(class_name, method_name, behaviour_runner)
        heckle.validate
      end
      
      def heckle_class_or_module(class_or_module_name)
        verify_constant(class_or_module_name)
        pattern = /^#{class_or_module_name}/
        classes = []
        ObjectSpace.each_object(Class) do |klass|
          classes << klass if klass.name =~ pattern
        end
        
        classes.each do |klass|
          klass.instance_methods(false).each do |method_name|
            heckle = @heckle_class.new(klass.name, method_name, behaviour_runner)
            heckle.validate
          end
        end
      end
      
      def verify_constant(name)
        begin
          # This is defined in Heckle
          name.to_class
        rescue
          raise "Heckling failed - \"#{name}\" is not a known class or module"
        end
      end
    end
    
    #Supports Heckle 1.2 and prior (earlier versions used Heckle::Base)
    class Heckler < (Heckle.const_defined?(:Base) ? Heckle::Base : Heckle)
      def initialize(klass_name, method_name, behaviour_runner)
        super(klass_name, method_name)
        @behaviour_runner = behaviour_runner
      end

      def tests_pass?
        paths = [] # We can pass an empty array of paths - our specs are already loaded.
        failure_count = @behaviour_runner.run(paths, false)
        failure_count == 0
      end
    end
  end
end
