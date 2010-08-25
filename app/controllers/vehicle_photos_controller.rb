class VehiclePhotosController < ApplicationController
  before_filter :extract_parameters

  def show
    render_widget
  end

  def create
    begin
     @vehicle.add_photo(params[:photo]) unless params[:photo].blank?
    rescue
    end
    render_widget
  end

  def set_primary
    @vehicle.set_primary_photo(params[:primary_photo_id].to_i)
    @vehicle.reload
    render_widget
  end

  def delete
    @vehicle.photos.delete_if do |photo|
      photo.destroy if photo.id == params[:delete_photo_id].to_i
    end
    render_widget
  end

  protected
  def extract_parameters
    find_vehicle
    @read_only = params[:read_only]
  end

  def find_vehicle
    id = (params[:vehicle_id] || params[:vehicle][:id]).to_i
    @vehicle = Vehicle.find(id)
  end

  def render_widget
    render :template => "/vehicle_photos/show", :layout => false
  end

end
