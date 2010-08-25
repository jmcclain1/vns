class AssetsAssociation < ActiveRecord::Base
  set_table_name :assets_associations
  belongs_to :asset
  belongs_to :associate, :polymorphic => true
  acts_as_list :scope => 'associate_id = #{associate_id} AND associate_type = #{quote_value associate_type}'
  validates_associated :asset
  before_create :make_primary_if_only_assets_association

  def make_primary_if_only_assets_association
    self.primary = true if associate.assets_associations.count == 0
  end
end