class NotificationsController < ApplicationController
  def index
    respond_to do |format|
      format.js  { render :action => 'index.rjs' }
    end
  end
end
