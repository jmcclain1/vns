class LatitudeLongitudeAreDoubles < ActiveRecord::Migration
  def self.up
    execute "alter table locations change column longitude longitude double;"
    execute "alter table locations change column latitude latitude double;"
  end

  def self.down
    execute "alter table locations change column longitude longitude float;"
    execute "alter table locations change column latitude latitude float;"
  end
end