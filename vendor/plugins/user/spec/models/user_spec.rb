require File.dirname(__FILE__) + '/../spec_helper'

describe "All fixtures" do
  it "should be valid" do
    User.find(:all).each do |user|
      next if user.needs_to_accept_tos?
      user.should be_valid
    end
  end
end

describe "A new user" do
  before(:each) do
    @user = new_user
  end

  it "should create a profile" do
    @user.profile.should be_nil
    @user.save
    @user.profile.should_not be_nil
  end

  it "should complain if password doesn't match confirmation" do
    @user.password_confirmation = "different"
    @user.should_not be_valid
    @user.errors.full_messages.should == ["Password does not match confirmation"]
  end

  it "should be able to set 'accept_terms_of_service' flag via set_attributes (for user creation)" do
    user = User.new(new_user_attributes.merge(:accept_terms_of_service => '1'))
    unique_name = user.unique_name
    user.accept_terms_of_service.should == '1'
    user.password = 'password'
    user.password_confirmation = 'password'

    user.should be_needs_to_accept_tos
    user.should be_valid
    user.save!
  end

  it "should not be valid if user has old tos but does not set 'accept_terms_of_service' flag" do
    user = users(:user_with_old_tos)
    user.accept_terms_of_service = '0'
    user.accept_terms_of_service.should == '0'
    user.terms_of_service_id.should == 2
    user.terms_of_service_id.should_not == TermsOfService.latest.id
    user.should be_needs_to_accept_tos
    user.save
    user.terms_of_service_id.should_not == TermsOfService.latest.id
    user.should_not be_valid
  end

  it "should be valid if user has old tos but sets 'accept_terms_of_service' flag" do
    user = users(:user_with_old_tos)
    user.accept_terms_of_service = '1'
    user.accept_terms_of_service.should == '1'
    user.save!
    user.should be_valid
    user.accept_terms_of_service == TermsOfService.latest
  end

  it "should complain if terms_of_service_id is not set" do
    user = users(:user_with_old_tos)
    user.terms_of_service_id = nil
    user.should_not be_valid
    user.errors.full_messages.should == ["Terms of service must be accepted"]
  end

  it "should complain if email address has a bad email format" do
    @user.email_address = "ba@demailaddress"
    @user.should_not be_valid
    @user.errors.full_messages.should == ["The email address you provided is not valid".customize]
  end

  it "should allow mixed case emails" do
    @user.email_address = "Ba@demailaddRess.com"
    @user.should be_valid
  end

  it "should allow dot and plus before @ and after the first character" do
    @user.email_address = "test.test@example.com"
    @user.should be_valid
    @user.email_address = ".test@example.com"
    @user.should_not be_valid
    @user.email_address = ".@example.com"
    @user.should_not be_valid

    @user.email_address = "test+@example.com"
    @user.should be_valid
    @user.email_address = "test+test@example.com"
    @user.should be_valid
  end

  it "should verify uniqueness independent of case" do
    @user.email_address = "Kevin@example.com"
    @user.save!
    @otheruser = User.new :unique_name => "kevin", :email_address => "kevin@example.com"
    @otheruser.password = "password"
    @otheruser.password_confirmation = "password"
    @otheruser.save

    @otheruser.should_not be_valid
  end

  it "should complain if email address is already taken" do
    @user.email_address = users(:valid_user).email_address
    @user.should_not be_valid
    @user.errors.full_messages.should == ["The email address you provided is already registered".customize]
  end

  it "should complain if unique name has already been taken" do
    @user.unique_name = users(:valid_user).unique_name
    @user.should_not be_valid
    @user.errors.full_messages.should == ["Unique name has already been taken".customize]
  end

  it "should complain if unique name has invalid characters" do
    @user.unique_name = 'bob!'
    @user.should_not be_valid
    @user.errors.full_messages.should == ["Unique name must be composed of letters, digits, underscores, or hyphens".customize]
  end

  it "should not complain if unique name has only valid characters" do
    @user.unique_name = 'b_o_b-9'
    @user.should be_valid
  end

  it "should complain if either password or password confirmation is omitted" do
    @user.password = ""
    @user.password_confirmation = ""
    @user.should_not be_valid
    @user.errors.full_messages.sort.should == ["Password is too short (minimum is 3 characters)", "Please enter your password",
      "Please confirm your password"].sort
  end

  it "should allow a unique name to be set" do
    @user.unique_name ="foo1212"
    @user.should be_valid
  end

  it "should start out unvalidated" do
    @user.save
    @user.should_not be_account_validated
    @user.should == User.find_by_id(@user.id)
  end

  it "should create user validation token" do
    @user.save
    @user.user_validation_tokens.should_not be_empty
  end
end

describe "An existing user" do
  before(:each) do
    @user = users(:valid_user)
  end

  it "should have a profile" do
    @user.profile.should == profiles(:for_valid_user)
  end

  it "should not be able to change their unique name" do
    @user.unique_name = "foo"
    @user.should_not be_valid
    @user.errors.full_messages.should == ["Unique name can't be changed"]
  end

  it "should update login activity when they receive a login! call" do
    @user.logins.destroy_all

    @user.login!
    @user.logins.size.should == 1
    first_login = @user.last_login

    @user.login!
    @user.logins.size.should == 2
    second_login = @user.last_login

    second_login.should be >= first_login
  end

  it "should use the profile's first and last name for the full name" do
    @user.full_name.should == "Bob McValid"
  end

  it "should use the username for the full name if the profile name is blank" do
    @user.profile.first_name = ""
    @user.profile.last_name = ""
    @user.full_name.should == "valid_bob"
  end

  it "should use the first name for the full name if the last name is blank" do
    @user.profile.last_name = ""
    @user.full_name.should == "Bob"
  end

  it "should use the last name for the full name if the first name is blank" do
    @user.profile.first_name = ""
    @user.full_name.should == "McValid"
  end

end

describe "Unvalidated users" do
  before(:each) do
    @user = users(:unvalidated_user)
  end

  it "should not be validated" do
    @user.should_not be_account_validated
  end

  it "should validate once they get a verify_account! call" do
    @user.verify_account!
    @user.reload
    @user.should be_account_validated
  end
end

describe "The authenticate method" do
  it "should find valid people by their password" do
    user = users(:valid_user)
    user.salt.should_not be_nil
    User.authenticate(:email_address => user.email_address, :password => "password").should == user
    User.authenticate(:email_address => user.email_address, :password => 'bad password').should be_nil
  end

  it "should find unvalidated users" do
    user = users(:unvalidated_user)
    User.authenticate(:email_address => user.email_address, :password => "password").should == user
  end

  it "should save tos if supplied" do
    TermsOfService.create!(:text => 'blah')
    user = users(:valid_user)
    user.should be_needs_to_accept_tos
    User.authenticate(:email_address => user.email_address, :password => "password", :accept_terms_of_service => '1')
    user.reload.should_not be_needs_to_accept_tos
  end

  it "should always save the user on successful authentication (this is important to after_save fires)" do
    user = users(:valid_user)
    original_update_time = user.updated_at
    User.authenticate(:email_address => user.email_address, :password => "password")
    user.reload
    user.updated_at.should > original_update_time
  end
end

describe "The password field" do
  it "should encrypt when called through the encrypt method" do
    password = "password"
    salt = "change-me"
    encrypted = User.encrypt(password, salt)
    encrypted.should == "db9c93f05d2e41dc2256c3890d5d78ca6e48d418"
  end

  it "should encrypt when saved" do
    user = users(:valid_user)
    user.current_password = "password"
    user.password = "new_password"
    user.password_confirmation = "new_password"
    user.save!
    user_from_db = User.find_by_email_address(user.email_address)
    User.authenticate(:email_address => user.email_address, :password => 'new_password').should == user_from_db
    user_from_db.encrypted_password.should == User.encrypt("new_password", user.salt)
  end
end

describe "Bulk setters" do
  it "should only set white list fields" do
    user = User.new(:unique_name => "unique name",
      :password => "password", :password_confirmation => "confirm",
      :email_address => "email@foo.com", :created_at => Clock.now, :updated_at => Clock.now)
    user.unique_name.should == "unique name"
    user.email_address.should == "email@foo.com"
    user.created_at.should be_nil
    user.updated_at.should be_nil
  end
end

describe User, "security: update and destroy" do
  fixtures :users

  it "admin can update and destroy" do
    users(:admin).can_update?(users(:valid_user)).should == true
    users(:admin).can_destroy?(users(:valid_user)).should == true
  end

  it "self can update and destroy" do
    users(:valid_user).can_update?(users(:valid_user)).should == true
    users(:valid_user).can_destroy?(users(:valid_user)).should == true
  end

  it "non-admin others can't update or destroy" do
    users(:second_valid_user).can_update?(users(:valid_user)).should == false
    users(:second_valid_user).can_destroy?(users(:valid_user)).should == false
  end

end

describe User, 'change password' do
  it "should not allow the changing of password without current password if no password reset token is present" do
    users(:valid_user).attributes = {:password => 'new_password', :password_confirmation => 'new_password'}
    users(:valid_user).save
    User.authenticate(:email_address => users(:valid_user).email_address, :password => 'new_password').should be_nil
  end

  it "should allow the changing of password without current password if a password reset token is present" do
    users(:valid_user).password_reset_tokens.create!
    users(:valid_user).attributes = {:password => 'new_password', :password_confirmation => 'new_password'}
    users(:valid_user).save
    User.authenticate(:email_address => users(:valid_user).email_address, :password => 'new_password').should == users(:valid_user)
  end

  it "should allow the changing of password if the current_password is correct" do
    users(:valid_user).attributes = {:current_password => 'password', :password => 'new_password', :password_confirmation => 'new_password'}
    users(:valid_user).save
    User.authenticate(:email_address => users(:valid_user).email_address, :password => 'new_password').should == users(:valid_user)
  end

  it "should not allow the changing of password if the current_password is incorrect" do
    users(:valid_user).attributes = {:current_password => 'incorrect', :password => 'new_password', :password_confirmation => 'new_password'}
    users(:valid_user).save
    users(:valid_user).errors[:current_password].should_not be_nil
    User.authenticate(:email_address => users(:valid_user).email_address, :password => 'new_password').should be_nil
  end
end