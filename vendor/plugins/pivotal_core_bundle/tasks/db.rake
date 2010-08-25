require File.dirname(__FILE__) + "/../lib/no_framework_bootstrap"
require "tmpdir"
require "tasks/db_tasks"

RakeTaskManager.clean("db:fixtures:load")
RakeTaskManager.clean("db:test:prepare")

namespace :db do
  desc "Drop and recreate dev and test databases and migrate"
  task(:init) {tasks.init}

  desc "Drop and recreate dev and test databases and migrate"
  task(:init_with_environment) {tasks.init_with_environment(ENV["RAILS_ENV"])}

  desc "Drop and recreate dev and test databases, migrate, and load fixtures"
  task(:setup) {tasks.setup}

  overridable_task :init_and_test do
    Rake::Task["db:setup"].invoke
    Rake::Task["testspec"].invoke
  end

  namespace :fixtures do
    # This differs from the standard db:fixtures:load only in that it turns off foreign key checking.
    desc "Load fixtures into the current environment's database.  Load specific fixtures using FIXTURES=x,y"
    task :load => :environment do
      require 'active_record/fixtures'
      ActiveRecord::Base.establish_connection(RAILS_ENV.to_sym)
      ActiveRecord::Base.connection.update('SET FOREIGN_KEY_CHECKS = 0') #nw - Turn off foreign keys while doing this
      (ENV['FIXTURES'] ? ENV['FIXTURES'].split(/,/) : Dir.glob(File.join(RAILS_ROOT, 'test', 'fixtures', '*.{yml,csv}'))).each do |fixture_file|
        Fixtures.create_fixtures('test/fixtures', File.basename(fixture_file, '.*'))
      end
      ActiveRecord::Base.connection.update('SET FOREIGN_KEY_CHECKS = 1') #nw - Turn ON foreign keys afterwards
    end
  end

  desc "Delete all data in the database."
  namespace :data do
    task(:delete) {tasks.delete_data(RAILS_ENV)}
  end

  def tasks
    DbTasks.new(self)
  end
end

# These tasks no longer does anything. This is overwritten to work with Virtual Enumerations.
namespace :db do
  namespace :test do
    task :prepare => :environment
  end
end
