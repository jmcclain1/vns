module UsersHelper
  def display_attr(instance_var_sym, attr_name)
    display_span_id = "#{instance_var_sym}_#{attr_name}"
    instance = instance_variable_get("@#{instance_var_sym}")
    
    mab = Markaby::Builder.new
    mab.p do
      label attr_name.to_s.humanize,
            :for => display_span_id
      tag! :br 
      span instance.send(attr_name),
           :id => display_span_id
    end
    return mab.to_s
  end
end