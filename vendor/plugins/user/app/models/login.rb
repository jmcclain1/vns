class Login < ActiveRecord::Base
  belongs_to :user

  def destroy
    self.destroyed_at = Time.now
    save
  end
end
