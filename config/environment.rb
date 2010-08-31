# The next line needs to begin with a space
 RAILS_GEM_VERSION = '1.2.3' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

POST_LOAD_BLOCKS = []

module Rails
  class Initializer
    def load_plugins
      find_plugins(configuration.plugin_paths).each {|path| load_plugin path}
      $LOAD_PATH.uniq!
    end
  end
end
# this is added so that we can get the GEM::Version::NUM_RE defined before it is used
# this should NOT be added to svn - foiund this solution on 
# http://groups.google.com/group/rubyonrails-talk/browse_thread/thread/484e09d92b2d9db4#a9adf1301cb66fc1
module Gem
  class Version
    NUM_RE = /\s*(\d+(\.\d+)*)*\s*/
  end
end 
Rails::Initializer.run do |config|
  config.plugin_paths = [
    RAILS_ROOT + '/vendor/plugins/prerequisites',
    RAILS_ROOT + '/vendor/plugins'
  ]
  config.action_controller.session_store = :active_record_store
end

ASSET_WORKER = Asset::Worker::Local.new
STORAGE_SERVICE = LocalDiskStorageService.new(RAILS_ROOT + "/public/assets/", "/assets/")

ActionController::Base.session_options[:session_key] = '_vns_session_id'
AutomaticMigration.migrate_if_necessary

ActionView::Base.field_error_proc = ERROR_PROCS[:errors_below]

POST_LOAD_BLOCKS.each { |proc| proc.call }

gem 'has_finder'
require 'has_finder'
require 'currency'
require 'action_view_extensions'
require 'active_record_extensions'
require 'rest_wizard'
require 'monkey'