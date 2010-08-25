class AddAssociationShimForTesting < ActiveRecord::Migration
  def self.up
    if ENV['RAILS_ENV'] == 'test'
      create_table :association_shims do |t|
        t.column "name", :string
      end
    end
  end

  def self.down
    drop_table :associations_shims
  end
end