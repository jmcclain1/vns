require 'active_record'
class ActiveRecord::Base
  def remove_attributes_protected_from_mass_assignment_with_raising(attributes)
    result = remove_attributes_protected_from_mass_assignment_without_raising(attributes)
    raise "You cannot have both attr_protected and attr_accessible attributes in the same AR object" if result.nil?
    result
  end

  alias_method_chain :remove_attributes_protected_from_mass_assignment, :raising
end