# SecureActions

module ActionController
 module Caching
  module Pages
   alias_method :old_expire_page, :expire_page
   def expire_page(options = {})
     old_expire_page(options.merge({:override_only_path => true}))
   end

   alias_method :old_cache_page, :cache_page
   def cache_page(content = nil, options = {})
     old_cache_page(content, options.merge({:override_only_path => true}))
   end   
  end
 end
end


module SecureActions
  def self.included(controller)
    Object.const_set(:USE_SSL, false) unless Object.constants.include? "USE_SSL"    
    controller.extend(ClassMethods)   
    controller.before_filter(:ensure_proper_protocol)
  end
  
  module ClassMethods
    def require_ssl(*actions)  
      ActionController::Base::SECURE[controller_name.to_sym] = actions
    end 
  end

  protected
  # Called as a before_filter in controllers that have some https:// actions
  def ensure_proper_protocol
    if !request.ssl? && USE_SSL && ssl_required?

      params = request.parameters.symbolize_keys
      params[:protocol] = 'https://'
      redirect_to params

      # redirect_to :protocol => 'https://', :action => action_name
      return false
    end
    return true
  end
  
  def ssl_required?
    secure = ActionController::Base::SECURE || {}
    controller = controller_name.to_sym
    actions = secure[controller] || []
    return actions.include?(action_name.to_sym) if action_name
    return false
  end

  # Called when URLs are generated
  def default_url_options(options)
    defaults = {}
    if USE_SSL
      my_controller = options[:controller] ? options[:controller].to_sym : nil

      # make sure class is loaded, gotcha!
      "#{my_controller.to_s.camelize}Controller".constantize if my_controller

      my_action = options[:action] ? options[:action].to_sym : nil
      my_controller = controller_name.to_sym if (my_action && my_controller.nil?)
      secure = ActionController::Base::SECURE

      options[:override_only_path] ? options[:only_path] = options[:override_only_path] : options[:only_path] = false
      if my_action.nil? && my_controller.nil?
        #Don't change the protocol if you stay on the same place
      elsif ((secure[my_controller] || []).include?(my_action))
        defaults[:protocol] = 'https://'
      else
        defaults[:protocol] = 'http://'
      end
    end
    options.delete :override_only_path
    return defaults
  end

end
    