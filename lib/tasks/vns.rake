dir = File.dirname(__FILE__)
require dir + "/../../vendor/plugins/pivotal_core_bundle/lib/no_framework_bootstrap"
require "evd_ii_updater"

RakeTaskManager.clean("alltests")

desc "Run all the tests, including Spec, and Selenium"

task :alltests do
  puts "\nRunning tests and specs"
  Rake::Task[:testspec].invoke

  puts "\nRunning selenium tests"
  Rake::Task['selenium:test'].invoke
end

task :testspec => :annotate_models do
  Rake::Task[:testspec_for_common].invoke
end

namespace :edmunds do
  task :import => :environment do
    EdImporter.new.import
  end

  task :load => :environment do
    EdImporter.new.load
  end
end

namespace :evd_ii do
  task :load => [:environment] do
    puts "\nLoading evd_ii data"
    EvdIiUpdater.new.load
  end
  task :load_small => [:environment] do
    puts "\nLoading evd_ii data, small dev version"
    EvdIiUpdater.new.load_small
  end
end

task :install_gems do
  ############# Begin GemInstaller config - see http://geminstaller.rubyforge.org
  require "rubygems"
  require "geminstaller"

  # Path(s) to your GemInstaller config file(s)
  config_paths = "#{File.expand_path(RAILS_ROOT)}/config/geminstaller.yml"

  # Arguments which will be passed to GemInstaller (you can add any extra ones)
  args = "--config #{config_paths}"

  # The 'exceptions' flag determines whether errors encountered while running GemInstaller
  # should raise exceptions (and abort Rails), or just return a nonzero return code
  args += " --exceptions"

  # This will use sudo by default on all non-windows platforms, but requires an entry in your
  # sudoers file to avoid having to type a password.  It can be omitted if you don't want to use sudo.
  # See http://geminstaller.rubyforge.org/documentation/documentation.html#dealing_with_sudo
  args += " --sudo" unless RUBY_PLATFORM =~ /mswin/

  # The 'install' method will auto-install gems as specified by the args and config
  GemInstaller.run(args)

  # The 'autogem' method will automatically add all gems in the GemInstaller config to your load path, using the 'gem'
  # or 'require_gem' command.  Note that only the *first* version of any given gem will be loaded.
#  GemInstaller.autogem(args)
  ############# End GemInstaller config
end
