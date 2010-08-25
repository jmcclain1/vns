module DefaultUserValidations
  def self.included(klass)
    klass.extend(ClassMethods)
    klass.class_eval do
      validates_presence_of :password,
                             :on => :create,
                             :message => "Please enter your password".customize
      validates_presence_of :password_confirmation,
                              :on => :save,
                              :if => lambda {|record| !record.password.nil?},
                              :message => "Please confirm your password".customize
      validates_presence_of :current_password,
                              :on => :update,
                              :if => lambda {|record| !record.password.nil? && record.password_reset_tokens.empty?},
                              :message => "Please confirm your password".customize
      validates_length_of :password,
                              :minimum=>3,
                              :on => :save,
                              :if => lambda {|record| !record.password.nil?}
      validates_confirmation_of :password,
                                :on => :save,
                                :message => "Password does not match confirmation".customize
      validates_each(:current_password, :on => :update) do |record, key, value|
        if !record.current_password.blank? && !User.authenticate(:email_address => record.email, :password => record.current_password)
          record.errors.add(key, "The password you entered does not match our records".customize)
        end
      end

      validates_format_of :email_address,
                          :with => RFC::EmailAddress,
                          :message => "The email address you provided is not valid".customize
      #validates_as_email :email_address, :message => "Email address is an invalid address".customize
      validates_uniqueness_of :email_address,
                              :message => "The email address you provided is already registered".customize

      validates_format_of :unique_name,
                          :with => /^[A-Za-z0-9_\-]+$/,
                          :message => "Unique name must be composed of letters, digits, underscores, or hyphens".customize

      validates_presence_of :unique_name,
                            :message => "Unique name can't be blank".customize
      validates_uniqueness_of :unique_name,
                              :message => "Unique name has already been taken".customize
      validates_immutability_of :unique_name,
                                :message => "Unique name can't be changed".customize

      validates_acceptance_of :accept_terms_of_service, :allow_nil => false,
                              :message => "Terms of service must be accepted".customize, :if => lambda {|user| user.needs_to_accept_tos?}
    end
  end

  module ClassMethods

    def validates_immutability_of(*attr_names)
      configuration = { :message => ActiveRecord::Errors.default_error_messages[:invalid], :on => :save, :with => nil }
      configuration.update(attr_names.pop) if attr_names.last.is_a?(Hash)

      validates_each(attr_names, configuration) do |record, attr_name, value|
        record.errors.add(attr_name, configuration[:message]) unless record.new_record? || self.find_by_id(record.id)[attr_name] == value
      end
    end
  end
end