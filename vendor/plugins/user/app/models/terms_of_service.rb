class TermsOfService < ActiveRecord::Base
  
  validates_presence_of :text
  
  def self.latest
    find(:first, :order => 'revision DESC')
  end
  
  def before_create
    self.revision = (TermsOfService.latest.revision + 1)
  end

  def readable_by?(user)
    true
  end
  
  def creatable_by?(user)
    user.super_admin?
  end

  def updatable_by?(user)
    user.super_admin?
  end

  def destroyable_by?(user)
    user.super_admin?
  end

end