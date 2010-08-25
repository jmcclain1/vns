require 'active_record'

module Changed
  module ClassMethods
    def update_parent_functor(parent_association)
      # note: reload is necessary where caching causes strange behavior.
      lambda do |record|
        if record.send(parent_association) && !record.send(parent_association).being_saved?
          record.send(parent_association).reload.child_has_changed(record)
        end
      end
    end

    def update_parent(parent_association, options = {:only => [:after_save, :after_destroy]})
      options[:only].each do |callback|
        send(callback, update_parent_functor(parent_association))
      end

      define_method :child_has_changed do |record|
        self.send(parent_association).child_has_changed(self)
      end
    end
  end

  module InstanceMethods
    def clean!
      changed_attributes = {}
    end

    def changed_attributes
      @changed_attributes ||= {}
    end

    def changed?
      changed_attributes.any? {|key, value| value}
    end

    def reload_with_clean!
      clean!
      reload_without_clean!
    end

    def write_attribute_with_changed(attr_name, value)
      if self[attr_name].to_s != value.to_s
        changed_attributes[attr_name] = true
      end
      write_attribute_without_changed(attr_name, value)
    end

    def attribute_changed?(attr)
      changed_attributes[attr]
    end

    def child_has_changed(child)
      save!
    end
  end
end

class ActiveRecord::Base
  include Changed::InstanceMethods
  extend Changed::ClassMethods

  after_save :clean!
  alias_method_chain :reload, :clean!
  alias_method_chain :write_attribute, :changed

  attribute_method_suffix '_changed?'

end