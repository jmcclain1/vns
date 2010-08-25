class ActionController::Base
  def secure_using_logged_in_user
    assert_security(params[:action])
    ActiveRecord::Base.as_user(logged_in_user) { yield }
  end

  private
  def assert_security(action)
    if respond_to?("can_#{params[:action]}?")
      die!(action) unless send("can_#{params[:action]}?")
    end
  end

  def die!(action)
    raise SecurityTransgression, "User '#{logged_in_user}' may not #{action} #{self.inspect}"
  end
end

VERB_TO_QUESTION_METHOD = {
  :create => :creatable_by?,
  :update => :updatable_by?,
  :destroy => :destroyable_by?,
  :read => :readable_by?
}

class ActiveRecord::Base
  @@acting_user = nil

  class << self
    def as_user(user, &block)
      begin
        @@acting_user = user
        yield
      ensure
        @@acting_user = nil
      end
    end

    def find_with_security_check(*args)
      result = self.find_without_security_check(*args)

      if result.is_a?(ActiveRecord::Base) and result.assert_security(:read)
        result.die!(:read)
      end

      return result
    end
    alias_method_chain :find, :security_check
  end

  def create_with_security_check(*args)
    assert_security(:create)
    create_without_security_check(*args)
  end
  alias_method_chain :create, :security_check

  def update_with_security_check(*args)
    assert_security(:update)
    update_without_security_check(*args)
  end
  alias_method_chain :update, :security_check

  def destroy_with_security_check(*args)
    assert_security(:destroy)
    destroy_without_security_check(*args)
  end
  alias_method_chain :destroy, :security_check

  def should_check_security?(verb)
    @@acting_user and self.respond_to?(VERB_TO_QUESTION_METHOD[verb])
  end

  def die!(verb)
    raise SecurityTransgression, "User '#{@@acting_user}' may not #{verb} #{self.inspect}[#{self.id}]"
  end

  def assert_security(verb)
    if should_check_security?(verb)
      unless @@acting_user.send("can_#{verb.to_s}?", self)
        die!(verb)
      end
    end
  end
end