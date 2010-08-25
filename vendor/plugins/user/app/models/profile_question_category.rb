class ProfileQuestionCategory < ActiveRecord::Base
  set_table_name :profile_question_categories

  acts_as_enumerated :order => 'sort_order asc'
  has_many :questions, :class_name => 'ProfileQuestion', :foreign_key => :category_id, :dependent => :destroy      
end