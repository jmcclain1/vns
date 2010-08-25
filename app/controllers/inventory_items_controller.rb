#TODO: is this necessary anymore? if not, kill it
class InventoryItemsController < ApplicationController
  def destroy
    vehicle = Vehicle.find(params[:id])

    vehicle.remove_from_inventory
    tablist_remove(params[:tab_id])

    redirect_to vehicles_path  
  end
end