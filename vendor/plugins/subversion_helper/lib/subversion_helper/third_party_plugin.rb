class ThirdPartyPlugin
  def initialize(name, options = {})
    @name = name
    @options = options
    @remote_repository_root = options[:remote_repository_root]
    @repository_root = "https://svn.pivotallabs.com/subversion/plugins/third_party/#{@name}"
    @remote_relative_path = options[:no_root_dir] ? @name : "."
  end

  attr_reader :name, :repository_root, :remote_repository_root, :options

  def update
    raise "Please provide a remote repository using REMOTE_SVN_ROOT parameter" unless @remote_repository_root
    remote_revision = current_remote_revision
    vendor_tag_name = vendor_tag_name(remote_revision)
    @msg = "rake third_party:update - updated to tag #{vendor_tag_name}"
    make_new_vendor_tag_and_refresh_vendor_branch(remote_revision, vendor_tag_name, true)
  end

  def install
    raise "Please provide a remote repository using REMOTE_SVN_ROOT parameter" unless @remote_repository_root
    remote_revision = current_remote_revision
    vendor_tag_name = vendor_tag_name(remote_revision)
    @msg = "rake third_party:install - plugin #{@name} installed from #{@remote_repository_root}"
    make_svn_directories
    make_new_vendor_tag_and_refresh_vendor_branch(remote_revision, vendor_tag_name, false)
    copy_to_local_branch(vendor_tag_name)
  end

  def make_local_branch
    raise "Please provide a VENDOR_TAG_NAME" if @options[:vendor_tag_name].nil?
    vendor_tag_name = vendor_tag_name(nil)
    @msg = "rake third_party:make_local_branch - made local branch from vendor tag #{vendor_tag_name}"
    copy_to_local_branch(vendor_tag_name)
  end

  def local_branch_diff
    raise "Please provide a VENDOR_TAG_NAME" if @options[:vendor_tag_name].nil?
    vendor_tag_name = vendor_tag_name(nil)
    puts `svn diff #{@repository_root}/tags/local_sprout_from_#{vendor_tag_name} #{@repository_root}/branches/local`
  end

  def vendor_tags
    puts `svn ls #{@repository_root}/tags`
  end

  private
  def make_svn_directories
    SubversionUtils.execute("svn mkdir #{@repository_root} -m '#{@msg}'")
    SubversionUtils.execute("svn mkdir #{@repository_root}/branches -m '#{@msg}'")
    SubversionUtils.execute("svn mkdir #{@repository_root}/tags -m '#{@msg}'")
  end

  def current_remote_revision
    remote_revision = SubversionUtils.get_revision_number(@remote_repository_root)
    say "Found remote revision #{remote_revision}"
    remote_revision
  end

  def make_new_vendor_tag_and_refresh_vendor_branch(remote_revision, vendor_tag_name, has_old_copy)
    FileUtils.in_fresh_tempdir do
      export_current_vendor_onto_current_dir(remote_revision)
      import_vendor_tag(vendor_tag_name)
    end
    replace_vendor_branch(vendor_tag_name, has_old_copy)
  end

  def checkout_latest_from_local_vendor_branch
    say "Checking out latest from local vendor branch"
    SubversionUtils.checkout("#{@repository_root}/branches/vendor")
  end

  def export_current_vendor_onto_current_dir(remote_revision)
    say "Exporting current vendor onto current dir"
    SubversionUtils.execute("svn export #{@remote_repository_root} #{@remote_relative_path} --force --revision=#{remote_revision}")
  end

  def import_vendor_tag(vendor_tag_name)
    say "Importing vendor tag #{vendor_tag_name}"
    SubversionUtils.execute("svn import . #{@repository_root}/tags/#{vendor_tag_name} -m '#{@msg}'")
  end

  def vendor_tag_name(remote_revision)
    @options[:vendor_tag_name] || "vendor_rev_#{remote_revision}"
  end

  def replace_vendor_branch(vendor_tag_name, has_old_copy)
    say "Copying tag #{vendor_tag_name} to vendor branch"
    if has_old_copy
      SubversionUtils.execute("svn rm #{@repository_root}/branches/vendor " +
        "-m '#{@msg}'")
    end
    SubversionUtils.execute("svn cp #{@repository_root}/tags/#{vendor_tag_name} #{@repository_root}/branches/vendor " +
      "-m '#{@msg}'")
  end

  def copy_to_local_branch(vendor_tag_name)
    if SubversionUtils.exists?("#{@repository_root}/branches/local")
      say "Removing old local branch"
      SubversionUtils.execute("svn rm #{@repository_root}/branches/local -m '#{@msg}'")
    end

    say "Copying tag #{vendor_tag_name} to local branch"
    SubversionUtils.execute("svn cp #{@repository_root}/tags/#{vendor_tag_name} #{@repository_root}/branches/local -m '#{@msg}'")
    say "Recording sprout tag local_sprout_from_#{vendor_tag_name}"
    SubversionUtils.execute("svn cp #{@repository_root}/tags/#{vendor_tag_name} #{@repository_root}/tags/local_sprout_from_#{vendor_tag_name} -m '#{@msg}'")
  end

  def say(msg)
    puts msg
  end

end