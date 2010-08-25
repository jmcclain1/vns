class ProfilePhotoAssociation < AssetsAssociation

  def updatable_by?(user)
    profile = associate

    return user == profile.user
  end

  def destroyable_by?(user)
    updatable_by?(user)
  end


end
