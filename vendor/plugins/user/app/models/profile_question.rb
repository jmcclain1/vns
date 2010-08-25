class ProfileQuestion < ActiveRecord::Base
  set_table_name :profile_questions
  
  acts_as_enumerated :order => 'sort_order asc'
  has_enumerated :category, :class_name => 'ProfileQuestionCategory'
  has_many :answers, :class_name => 'ProfileAnswers', :dependent => :destroy
end