namespace :db do
  namespace :migrate do
    desc 'Migrate the database through scripts in plugin_xyz/db/migrate. Target specific plugin with PLUGIN=x, specific version with VERSION=y'
    task :plugins => :environment do
      PluginAWeek::PluginMigrations.migrate(ENV['PLUGIN'], ENV['VERSION'])
      Rake::Task['db:schema:dump'].invoke if ActiveRecord::Base.schema_format == :ruby
    end
  end
  
  namespace :fixtures do
    namespace :load do
      desc "Load plugin fixtures into the current environment's database.  Load fixtures for a specific plugin using PLUGIN=x, specific fixtures using FIXTURES=y,z"
      task :plugins => :environment do
        PluginAWeek::PluginMigrations.load_fixtures(ENV['PLUGIN'], ENV['FIXTURES'])
      end
    end
  end
end