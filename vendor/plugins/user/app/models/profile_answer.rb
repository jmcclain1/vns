class ProfileAnswer < ActiveRecord::Base
  set_table_name :profile_answers
  belongs_to :profile
  has_enumerated :question, :class_name => "ProfileQuestion"
  acts_as_list :scope => :question

  def to_s
    value || ''
  end
end
