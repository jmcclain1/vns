class UsersController < ApplicationController
  before_filter :remove_non_digits_from_phone_number, :only => [:update]

  def show
  end

  def edit
  end

  def update
    @user = logged_in_user
    @user.attributes = params[:user]
    if @user.save
      save_user_success
    else
      save_user_failure
    end
  end

  private

  def save_user_success
    redirect_to user_url(@user)
  end

  def save_user_failure
    flash[:notice] = @user.errors.full_messages
    redirect_to edit_user_url(@user)
  end

  def remove_non_digits_from_phone_number
    address = params[:user][:sms_address]
    if (address && index_of_at = address.index('@'))
      params[:user][:sms_address] = address[0...index_of_at].gsub(/[^\d]/, '') + address[index_of_at..-1]
    end
  end
end
