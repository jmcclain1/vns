dir = File.dirname(__FILE__)
require "#{dir}/spec_helper"

describe "A ThirdPartyPlugin" do
  before do
    @plugin = ThirdPartyPlugin.new("fake",
      :remote_repository_root => "svn:whatever")
    @local_svn_root = "https://svn.pivotallabs.com/subversion/plugins/third_party/fake"
    SubversionUtils.stub!(:execute).and_return {raise "Neutered execute"}
    @plugin.stub!(:say)
  end

  it "should initialize" do
    @plugin.name.should == "fake"
    @plugin.repository_root.should == "https://svn.pivotallabs.com/subversion/plugins/third_party/fake"
    @plugin.remote_repository_root.should == "svn:whatever"
    @plugin.options[:vendor_tag_name].should be_nil
  end

  it "should install" do
    msg = "-m 'rake third_party:install - plugin fake installed from svn:whatever'"
    SubversionUtils.should_receive(:execute).ordered.
      with("svn info svn:whatever | grep Revision | cut -f 2 -d' '").and_return("25")
    SubversionUtils.should_receive(:execute).ordered.
      with("svn mkdir #{@local_svn_root} #{msg}")
    SubversionUtils.should_receive(:execute).ordered.
      with("svn mkdir #{@local_svn_root}/branches #{msg}")
    SubversionUtils.should_receive(:execute).ordered.
      with("svn mkdir #{@local_svn_root}/tags #{msg}")
    SubversionUtils.should_receive(:execute).ordered.
      with("svn export svn:whatever . --force --revision=25")
    SubversionUtils.should_receive(:execute).ordered.
      with("svn import . #{@local_svn_root}/tags/vendor_rev_25 #{msg}")
    SubversionUtils.should_receive(:execute).ordered.
      with("svn cp #{@local_svn_root}/tags/vendor_rev_25 #{@local_svn_root}/branches/vendor #{msg}")
    SubversionUtils.should_receive(:execute).ordered.
      with("svn cp #{@local_svn_root}/tags/vendor_rev_25 #{@local_svn_root}/branches/local #{msg}")
    SubversionUtils.should_receive(:execute).ordered.
      with("svn cp #{@local_svn_root}/tags/vendor_rev_25 #{@local_svn_root}/tags/local_sprout_from_vendor_rev_25 #{msg}")
    @plugin.install
  end

  it "should update" do
    msg = "-m 'rake third_party:update - updated to tag vendor_rev_25'"
    SubversionUtils.should_receive(:execute).ordered.
      with("svn info svn:whatever | grep Revision | cut -f 2 -d' '").and_return("25")
    SubversionUtils.should_receive(:execute).ordered.
      with("svn export svn:whatever . --force --revision=25")
    SubversionUtils.should_receive(:execute).ordered.
      with("svn import . #{@local_svn_root}/tags/vendor_rev_25 #{msg}")
    SubversionUtils.should_receive(:execute).ordered.
      with("svn rm #{@local_svn_root}/branches/vendor #{msg}")
    SubversionUtils.should_receive(:execute).ordered.
      with("svn cp #{@local_svn_root}/tags/vendor_rev_25 #{@local_svn_root}/branches/vendor #{msg}")
    @plugin.update
  end

  it "should not allow you to make a local branch without providing a vendor tag" do
    lambda {@plugin.make_local_branch}.should raise_error(RuntimeError, "Please provide a VENDOR_TAG_NAME")
  end
end

describe "A ThirdPartyPlugin that points to a vendor tag rather than a revision" do
  before do
    @plugin = ThirdPartyPlugin.new("fake",
      :remote_repository_root => "svn:whatever",
      :vendor_tag_name => "vendor_tag")
    @local_svn_root = "https://svn.pivotallabs.com/subversion/plugins/third_party/fake"
    SubversionUtils.stub!(:execute).and_return {raise "Neutered execute"}
    @plugin.stub!(:say)
  end

  it "should install to a vendor tag named after itself" do
    msg = "-m 'rake third_party:install - plugin fake installed from svn:whatever'"
    SubversionUtils.should_receive(:execute).ordered.
      with("svn info svn:whatever | grep Revision | cut -f 2 -d' '").and_return("25")
    SubversionUtils.should_receive(:execute).ordered.
      with("svn mkdir #{@local_svn_root} #{msg}")
    SubversionUtils.should_receive(:execute).ordered.
      with("svn mkdir #{@local_svn_root}/branches #{msg}")
    SubversionUtils.should_receive(:execute).ordered.
      with("svn mkdir #{@local_svn_root}/tags #{msg}")
    SubversionUtils.should_receive(:execute).ordered.
      with("svn export svn:whatever . --force --revision=25")
    SubversionUtils.should_receive(:execute).ordered.
      with("svn import . #{@local_svn_root}/tags/vendor_tag #{msg}")
    SubversionUtils.should_receive(:execute).ordered.
      with("svn cp #{@local_svn_root}/tags/vendor_tag #{@local_svn_root}/branches/vendor #{msg}")
    SubversionUtils.should_receive(:execute).ordered.
      with("svn cp #{@local_svn_root}/tags/vendor_tag #{@local_svn_root}/branches/local #{msg}")
    SubversionUtils.should_receive(:execute).ordered.
      with("svn cp #{@local_svn_root}/tags/vendor_tag #{@local_svn_root}/tags/local_sprout_from_vendor_tag #{msg}")
    @plugin.install
  end

  it "should update to a vendor tag named after itself" do
    msg = "-m 'rake third_party:update - updated to tag vendor_tag'"
    SubversionUtils.should_receive(:execute).ordered.
      with("svn info svn:whatever | grep Revision | cut -f 2 -d' '").and_return("25")
    SubversionUtils.should_receive(:execute).ordered.
      with("svn export svn:whatever . --force --revision=25")
    SubversionUtils.should_receive(:execute).ordered.
      with("svn import . #{@local_svn_root}/tags/vendor_tag #{msg}")
    SubversionUtils.should_receive(:execute).ordered.
      with("svn rm #{@local_svn_root}/branches/vendor #{msg}")
    SubversionUtils.should_receive(:execute).ordered.
      with("svn cp #{@local_svn_root}/tags/vendor_tag #{@local_svn_root}/branches/vendor #{msg}")
    @plugin.update
  end

  it "should allow you to refresh a local branch from this tag" do
    msg = "-m 'rake third_party:make_local_branch - made local branch from vendor tag vendor_tag'"
    SubversionUtils.should_receive(:exists?).with("#{@local_svn_root}/branches/local").and_return(false)
    SubversionUtils.should_receive(:execute).ordered.
      with("svn cp #{@local_svn_root}/tags/vendor_tag #{@local_svn_root}/branches/local #{msg}")
    SubversionUtils.should_receive(:execute).ordered.
      with("svn cp #{@local_svn_root}/tags/vendor_tag #{@local_svn_root}/tags/local_sprout_from_vendor_tag #{msg}")
    @plugin.make_local_branch
  end

  it "should remove old local branch before creating new local branch" do
    msg = "-m 'rake third_party:make_local_branch - made local branch from vendor tag vendor_tag'"
    SubversionUtils.should_receive(:exists?).with("#{@local_svn_root}/branches/local").and_return(true)
    SubversionUtils.should_receive(:execute).ordered.
      with("svn rm #{@local_svn_root}/branches/local #{msg}")
    SubversionUtils.should_receive(:execute).ordered.
      with("svn cp #{@local_svn_root}/tags/vendor_tag #{@local_svn_root}/branches/local #{msg}")
    SubversionUtils.should_receive(:execute).ordered.
      with("svn cp #{@local_svn_root}/tags/vendor_tag #{@local_svn_root}/tags/local_sprout_from_vendor_tag #{msg}")
    @plugin.make_local_branch
  end
end

describe "A ThirdPartyPlugin that doesn't start from a plugin directory" do
  before do
    @plugin = ThirdPartyPlugin.new("fake",
      :remote_repository_root => "svn:whatever", :no_root_dir => true)
    @local_svn_root = "https://svn.pivotallabs.com/subversion/plugins/third_party/fake"
    SubversionUtils.stub!(:execute).and_return {raise "Neutered execute"}
    @plugin.stub!(:say)
  end

  it "should export into a subdirectory that matches the plugin name" do
    msg = "-m 'rake third_party:update - updated to tag vendor_rev_25'"
    SubversionUtils.should_receive(:execute).ordered.
      with("svn info svn:whatever | grep Revision | cut -f 2 -d' '").and_return("25")
    SubversionUtils.should_receive(:execute).ordered.
      with("svn export svn:whatever fake --force --revision=25")
    SubversionUtils.should_receive(:execute).ordered.
      with("svn import . #{@local_svn_root}/tags/vendor_rev_25 #{msg}")
    SubversionUtils.should_receive(:execute).ordered.
      with("svn rm #{@local_svn_root}/branches/vendor #{msg}")
    SubversionUtils.should_receive(:execute).ordered.
      with("svn cp #{@local_svn_root}/tags/vendor_rev_25 #{@local_svn_root}/branches/vendor #{msg}")
    @plugin.update
  end
end
