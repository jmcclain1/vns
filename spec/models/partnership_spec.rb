require File.dirname(__FILE__) + '/../spec_helper'

describe Partnership do
  it "can refer to a receiver and a inviter" do
    charlie = users(:charlie)
    bob = users(:bob)
    p = Partnership.create!(:inviter => charlie, :receiver => bob,
                        :accepted => false)

    p.receiver.should == bob
    p.inviter.should == charlie
  end

  it "does not allow a user to partner with himself" do
    charlie = users(:charlie)
    p = Partnership.new(:inviter => charlie, :receiver => charlie)
    p.valid?
    
    p.should have(1).errors_on(:receiver)
  end

  it "does not allow a duplicate partnership to be created" do
    charlie = users(:charlie)
    bob = users(:bob)

    p1 = Partnership.create(:inviter => charlie, :receiver => bob)
    p1.valid?.should == true

    p2 = Partnership.new(:inviter => charlie, :receiver => bob)
    p2.valid?
    p2.should have(1).errors_on(:receiver_id)
  end
end

describe Partnership, "paginating and sorting" do
  it "returns all partners ordered by date added by default" do
    bob = users(:bob)
    add_partner(:inviter => bob, :receiver => users(:alice))
    add_partner(:inviter => bob, :receiver => users(:charlie))
    add_partner(:inviter => bob, :receiver => users(:rob))

    partners = Partnership.paginate(:user => bob)
    partners.size.should == 3
    partners.first.should == users(:alice)
    partners.last.should == users(:rob)
  end

  it "does not return partners for receivers who have not yet approved those partners" do
    charlie = users(:charlie)
    add_partner(:inviter => users(:bob), :receiver => charlie)
    add_partner(:inviter => users(:cathy), :receiver => charlie)
    add_partner(:inviter => charlie, :receiver => users(:rob))

    partners = Partnership.paginate(:user => charlie)
    partners.size.should == 1
    partners.first.should == users(:rob)
  end

  it "honors the offset and page_size parameters" do
    bob = users(:bob)
    add_partner(:inviter => bob, :receiver => users(:alice))
    add_partner(:inviter => bob, :receiver => users(:charlie))
    add_partner(:inviter => bob, :receiver => users(:rob))
    add_partner(:inviter => bob, :receiver => users(:cathy))

    partners = Partnership.paginate(:user => bob, :page_size => 3)
    partners.first.should == users(:alice)
    partners.size.should == 3

    partners = Partnership.paginate(:user => bob, :offset => 2)
    partners.first.should == users(:rob)
    partners.size.should == 2
  end

  it "can order by the entire full name firstname + lastname (s0)" do
    bob = users(:bob)
    add_partner(:inviter => bob, :receiver => users(:rob))
    add_partner(:inviter => bob, :receiver => users(:charlie))
    add_partner(:inviter => bob, :receiver => users(:alice))
    add_partner(:inviter => bob, :receiver => users(:rob2))
    add_partner(:inviter => bob, :receiver => users(:cathy))

    partners = Partnership.paginate(:user => bob, :s0 => 'ASC')
    partners.first.should == users(:alice)

    # Rob and Rob2 have the exact same name. Also want to make sure that it sorts by name, id.
    # Rob2's was added as a partner later, so he should be after rob
    partners.last.should == users(:rob2)
  end

  it "can order by screen name (s1)" do
    bob = users(:bob)
    add_partner(:inviter => bob, :receiver => users(:rob))
    add_partner(:inviter => bob, :receiver => users(:charlie))
    add_partner(:inviter => bob, :receiver => users(:alice))
    add_partner(:inviter => bob, :receiver => users(:cathy))

    partners = Partnership.paginate(:user => bob, :s1 => 'DESC')
    partners.first.should == users(:rob)
    partners.last.should == users(:alice)
  end

  it "can order by distance" do
    bob = users(:bob)
    add_partner(:inviter => bob, :receiver => users(:charlie))
    add_partner(:inviter => bob, :receiver => users(:rob))
    add_partner(:inviter => bob, :receiver => users(:cathy))

    partners = Partnership.paginate(:user => bob, :s2 => 'ASC')
    partners.first.should == users(:rob)
    partners.last.should == users(:cathy)

    partners = Partnership.paginate(:user => bob, :s2 => 'DESC')
    partners.first.should == users(:cathy)
    partners.last.should == users(:rob)

    partners = Partnership.paginate(:user => bob, :s2 => 'DESC', :offset => 1)
    partners.first.should == users(:charlie)
    partners.last.should == users(:rob)
  end

  it "can order by status" do
    bob = users(:bob)
    add_partner(:inviter => bob, :receiver => users(:charlie))
    add_partner(:inviter => bob, :receiver => users(:alice))
    add_partner(:inviter => bob, :receiver => users(:cathy))

    partners = Partnership.paginate(:user => bob, :s3 => 'ASC')
    partners.first.should == users(:charlie)
    partners.last.should == users(:alice)

    partners = Partnership.paginate(:user => bob, :s3 => 'DESC')
    partners.first.should == users(:alice)
    partners.last.should == users(:charlie)
  end

  private
  def add_partner(args)
    Partnership.create!(:inviter => args[:inviter],
                        :receiver => args[:receiver])
  end
end