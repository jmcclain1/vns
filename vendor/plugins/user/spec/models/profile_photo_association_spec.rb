require File.dirname(__FILE__) + '/../spec_helper'



describe ProfilePhotoAssociation, "security: update and destroy" do

  it "photo creator can update or destroy (and no one else)" do
    association = ProfilePhotoAssociation.new(:asset => assets(:basic_1), :associate => profiles(:for_valid_user))

    users(:valid_user).can_update?(association).should == true
    users(:valid_user).can_destroy?(association).should == true
    
    users(:second_valid_user).can_update?(association).should == false
    users(:second_valid_user).can_destroy?(association).should == false
  end


end


