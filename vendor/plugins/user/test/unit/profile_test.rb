require File.dirname(__FILE__) + '/../test_helper'

class ProfileTest < UserPluginTestCase
  def setup
    super
    @profile = profiles(:for_valid_user)
  end

  def test_categories_with_answers
    assert_equal [ProfileQuestionCategory[:personal_info]], @profile.categories_with_answers
  end  
  
  def test_categories_with_answers__returns_categories_that_only_contain_answered_questions
    category = @profile.categories_with_answers[0]
    
    assert_equal [ProfileQuestion[:sign], ProfileQuestion[:age], ProfileQuestion[:display_name]], category.questions
  end
  
  def test_answers_in_category
    assert_equal [profile_answers(:sign_answer_two_of_basic), profile_answers(:sign_answer_one_of_basic), profile_answers(:age_answer_of_basic), profile_answers(:display_name_answer_of_basic)], @profile.answers_in_category(ProfileQuestionCategory[:personal_info])
  end

  def test_answers_for_questions__returns_multiple_answers
    question = profile_questions(:sign)
    answer1 = profile_answers(:sign_answer_one_of_basic)
    answer2 = profile_answers(:sign_answer_two_of_basic)
    assert answer1.position > answer2.position
    assert_equal([answer2, answer1], @profile.answers_for_question(question))
  end

  def test_update_answers
    assert_equal '400', @profile.age.to_s
    @profile.update_answers!({'age' => '500'})
    
    @profile.reload
    assert_equal '500', @profile.age.to_s
  end

  def test_primary_photo
    assert_not_nil @profile.photos.first
    assert_equal(@profile.photos.first, @profile.primary_photo)
  end

  def test_primary_photo__profile_is_not_creator
    photo = assets(:basic_2)
    photo.creator_id = 99999
    photo.save!
    association = ProfilePhotoAssociation.create!(:associate => @profile, :asset => photo)
    @profile.reload
    photo.reload
    assert_not_equal photo, @profile.primary_photo

    association.move_to_top
    association.reload
    @profile.reload
    photo.reload
    assert_equal photo, @profile.primary_photo
  end

  def test_photos__only_includes_photos
    video = assets(:video)
    association = AssetsAssociation.create!(:associate => @profile, :asset => video)
    @profile.reload

    @profile.photos.each do |photo|
      assert_true photo.is_a?(ProfilePhoto)
    end
  end
  
  def test_primary_photo__profile_without_photo__placeholder_photo
    AssetsAssociation.destroy_all
    assert_nil @profile.photos.first
    assert_instance_of DefaultPhoto, @profile.primary_photo
  end

  def test_primary_photo_equals__already_has_photo
    first_photo = @profile.photos[0]
    second_photo = @profile.photos[1]
    count = @profile.photos.size
    assert_equal first_photo, @profile.primary_photo
    @profile.primary_photo = second_photo
    @profile.reload
    first_photo.reload
    second_photo.reload
    assert_equal second_photo, @profile.primary_photo
    assert_equal count, @profile.photos.size
  end

  def test_primary_photo_equals__does_not_have_photo
    new_photo = assets(:basic_2)
    assert_not_equal new_photo, @profile.primary_photo
    @profile.primary_photo = new_photo
    @profile.reload
    assert_equal new_photo, @profile.primary_photo
  end

  def test_profile_can_be_associated_with_stock_photo
    stock_photo = assets(:stock_photo_1)
    @profile.primary_photo = stock_photo
    stock_photo.reload
    @profile.reload
    assert_equal stock_photo, @profile.primary_photo
  end

  def test_method_missing
    assert_equal ['Virgo Rising', 'Pisces'], @profile.sign.collect(&:to_s)
    assert_equal '400', @profile.age.to_s
    assert_raises(NoMethodError) { @profile.junk.to_s }
  end
end