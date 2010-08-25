require File.dirname(__FILE__) + '/../spec_helper'

describe TermsOfService do
  before do
    @tos_rev_2 = terms_of_services(:tos_rev_2)
    @tos_rev_3 = terms_of_services(:tos_rev_3)
  end
  
  it "should have fixtures with a text and revision" do

    @tos_rev_2.text.should_not be_nil
    @tos_rev_3.text.should_not be_nil

    @tos_rev_2.revision.should == 2
    @tos_rev_3.revision.should == 3
  end
  
  it "should return the latest terms of service" do
    TermsOfService.latest.revision.should == @tos_rev_3.revision
  end
  
  it "should create with incremented revision" do
    previous_revision = TermsOfService.latest.revision
    tos = TermsOfService.create!(:text => 'zzz')
    tos.text.should == 'zzz'
    TermsOfService.latest.revision.should == (previous_revision + 1)
  end
  
  it "should not create with no text" do
    tos = TermsOfService.create
    tos.should_not be_valid
  end

  it 'should be readable by non super admin' do
    non_admin_user = users(:valid_user)
    non_admin_user.can_read?(TermsOfService.new).should == true
  end

  it 'should be readable by super admin' do
    admin_user = users(:admin)
    admin_user.can_read?(TermsOfService.new).should == true
  end

  it 'should not be creatable by non super admin' do
    non_admin_user = users(:valid_user)
    non_admin_user.can_create?(TermsOfService.new).should == false
  end

  it 'should be creatable by super admin' do
    admin_user = users(:admin)
    admin_user.can_create?(TermsOfService.new).should == true
  end
end