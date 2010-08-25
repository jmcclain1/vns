class Profile < ActiveRecord::Base
  set_table_name :profiles
  
  belongs_to :user
  has_many :answers, :dependent => :destroy, :class_name => 'ProfileAnswer', :order => 'position ASC'
  include Photoable.new(ProfilePhoto, {:extension => 'gif', :association_class => ProfilePhotoAssociation})

  def unique_name
    user.unique_name
  end

  def empty?
    answers.empty?
  end

  def answer_for_question(question)
    answers.find_by_question_id(question.id, :order => 'position ASC')
  end

  def answers_for_question(question)
    answers.find_all_by_question_id(question.id, :order => 'position ASC')
  end

  def categories_with_answers
    ProfileQuestionCategory.all.select do |category|
      answers_in_category(category).size > 0
    end
  end

  def answers_in_category(category)
    category.questions.collect { |question| answers_for_question(question) }.flatten.compact
  end

  def update_answers!(answers_hash)
    answers.clear
    return if answers_hash.nil?
    answers_hash.each do |question_name, answer_value|
      answers.create(:question => ProfileQuestion[question_name.to_sym],
                     :value => answer_value) unless answer_value.blank?
    end
  end

  def primary_photo_id
    primary_photo.id
  end

  def primary_photo=(photo)
    if assoc = assets_associations.find_by_asset_id(photo.id)
      assoc.move_to_top
    else
      assets_associations.create!(:asset => photo).move_to_top
    end
  end

  def non_stock_photos
    self.photos.reject do |photo|
      photo.is_a? StockProfilePhoto
    end
  end

  def method_missing(method_name, *args, &block)
    return super unless ProfileQuestion.include?(method_name)

    answers = answers_for_question(ProfileQuestion[method_name])
    answers.size > 1 ? answers : answers.first
  end

  def creatable_by?(acting_user)
    user.creatable_by?(acting_user)
  end

  def updatable_by?(acting_user)
    self.user == acting_user || acting_user.super_admin?
  end

  def destroyable_by?(acting_user)
    updatable_by?(acting_user)
  end
end