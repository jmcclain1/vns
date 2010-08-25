module ProfilesHelper
  def question_field(profile, question)
    case question
      when TextFieldProfileQuestion
        text_field_tag "profile[answers][#{question.name}]",
                        profile.answer_for_question(question),
                        :size => 40
      when TextAreaProfileQuestion
        text_area_tag "profile[answers][#{question.name}]",
  			              profile.answer_for_question(question),
  			              :rows => '8',
  			              :cols => '38'
    end
  end

  def profile_link(profile, link_text = profile.user.to_s)
    link_to link_text, :controller => :profiles, :action => :show, :identifier => profile.unique_name
  end

  def view_all_photos_link( profile)
    link_to( 'View All', :controller => 'photos', :action => 'list', :id => profile.id ) unless profile.photos.empty?
  end
end