require File.dirname(__FILE__) + '/../spec_helper'


describe "model create and update" do
  setup do
    @not_admin = users(:valid_user)
    @admin = users(:admin)
  end

  it "can create if you're not in a user-constrained mode" do
    proc { TermsOfService.new(:text => "original text").save! }.should_not raise_error(SecurityTransgression)
  end

  it "can't create if you're not allowed to" do
    @not_admin.can_create?(TermsOfService.new(:text => "original text")).should == false

    ActiveRecord::Base.as_user(@not_admin) do
      original_tos_count = TermsOfService.count(:id, {})

      proc { TermsOfService.new(:text => "original text").save! }.should raise_error(SecurityTransgression)
      TermsOfService.count(:id, {}).should == original_tos_count

      proc { TermsOfService.create!(:text => "original text") }.should raise_error(SecurityTransgression)
      TermsOfService.count(:id, {}).should == original_tos_count
    end
  end

  it "can update if you're not in a user-constrained mode" do
    tos = TermsOfService.create!(:text => "original text")
    tos.text = "my tos text"
    proc { tos.save! }.should_not raise_error(SecurityTransgression)
    TermsOfService.find(tos.id).text.should == "my tos text"
  end

  it "can't update if you're not allowed to" do
    tos = TermsOfService.create!(:text => "original text")
    @not_admin.can_update?(tos).should == false
    tos.text = "my tos text"

    ActiveRecord::Base.as_user(@not_admin) do
      proc { tos.save! }.should raise_error(SecurityTransgression)
    end

    TermsOfService.find(tos.id).text.should == "original text"
  end

  it "can destroy if you're not in a user-constrained mode" do
    tos = TermsOfService.create!(:text => "original text")

    proc { tos.destroy }.should_not raise_error(SecurityTransgression)
    TermsOfService.find_by_id(tos.id).should be_nil
  end

  it "can't destroy if you're not allowed to" do
    tos = TermsOfService.create!(:text => "original text")
    @not_admin.can_destroy?(tos).should == false

    ActiveRecord::Base.as_user(@not_admin) do
      proc { tos.destroy }.should raise_error(SecurityTransgression)
    end

    TermsOfService.find(tos.id).should == tos
  end

end

describe "model retrieval" do
  setup do
    @not_admin = users(:valid_user)
    @admin = users(:admin)
  end

  it "can find if you're not in a user-constrained mode" do
    tos = TermsOfService.create!(:text => "original text")
    proc { TermsOfService.find(tos.id) }.should_not raise_error(SecurityTransgression)
    TermsOfService.find(tos.id).should == tos
  end

  it "can't find if you're not allowed to" do
    login_activity = LoginActivity.create!(:user => users(:second_valid_user))
    @not_admin.can_read?(login_activity).should == false

    ActiveRecord::Base.as_user(@not_admin) do
      proc { LoginActivity.find(login_activity.id) }.should raise_error(SecurityTransgression)
    end
  end
end

describe "objects that don't need to be secure" do
  setup do
    @not_admin = users(:valid_user)
    @admin = users(:admin)
    @photo = ProfilePhoto.new(:source_uri=>"http://foo")
  end

  it "anyone can create an object that's not secure" do
    ActiveRecord::Base.as_user(@not_admin) do
      @photo.save!
    end

    ProfilePhoto.find(@photo.id).should_not be_nil
  end

  it "anyone can update an object that's not secure" do
    ActiveRecord::Base.as_user(@not_admin) do
      @photo.original_filename = "foo"
      @photo.save!
    end

    ProfilePhoto.find(@photo.id).original_filename.should == "foo"
  end

  it "anyone can destroy an object that's not secure" do
    @photo.save!
    ActiveRecord::Base.as_user(@not_admin) do
      @photo.destroy
    end

    ProfilePhoto.exists?(@photo.id).should be_false
  end

  it "anyone can look up an object that's not secure" do
    @photo.save!
    ActiveRecord::Base.as_user(@not_admin) do
      ProfilePhoto.find(@photo.id).should_not be_nil
    end

  end
end