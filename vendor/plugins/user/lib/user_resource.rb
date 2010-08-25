module UserResource
#  include UserAuthorization
  # include this in classes that are subordinate to user
  def self.included(klass)
    klass.class_eval do
      before_filter :load_user
    end
  end

  protected
  def load_user
    @user ||= User.find_by_unique_name(params[:user_id])
  end

end