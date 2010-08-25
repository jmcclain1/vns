class EvdMigration < ActiveRecord::Migration
  protected
  def self.migrate_evd
    ActiveRecord::Base.establish_connection :evd_rw
    yield
    ActiveRecord::Base.establish_connection RAILS_ENV
  end
end
