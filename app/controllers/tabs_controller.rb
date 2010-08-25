class TabsController < ApplicationController
  def destroy
    id = params[:id]
    if tab = session[:tablist][id]
      session[:tablist].delete(id)
    end
    render :nothing => true
  end
end
