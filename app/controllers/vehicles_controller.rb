class VehiclesController < ApplicationController
  wizard :wizard,
         :steps => {1 => {:name => 'trim', :template => '/vehicles/wizard/trim'},
                    2 => {:name => 'details', :template => '/vehicles/wizard/details'},
                    3 => {:name => 'add_photos', :template => '/vehicles/wizard/add_photos'},
                    4 => {:name => 'summary', :template => '/vehicles/wizard/summary'}
                    }

  before_filter :set_dealership

  def index
    respond_to do |format|
      format.html
      format.js  { extract_livegrid_params(params)
                   render :layout => false,
                          :content_type => 'application/xml',
                          :action => "index.rxml" }
    end
  end

  def show
    @vehicle ||= logged_in_user.dealership.all_vehicles.find(params[:id])

    @checkbox_check_standard_feature = !params[:checkbox_check_standard_feature].blank?

    render :template => wizard.current_step_template if wizard.active?
  end

  def new
    @vehicle ||= Vehicle.new
    render :template => '/vehicles/wizard/vin'
  end

  def edit
    @vehicle = logged_in_user.dealership.all_vehicles.find(params[:id])
  end

  def create
    attributes = {:dealership => @dealership}
    attributes.merge!(params[:vehicle])

    @vehicle = Vehicle.new(attributes)
    @vehicle.valid?

    vin_error = "We could not locate that VIN in our database. Please try again."

    if @vehicle.errors.on(:vin).nil?
      trims = Evd::Trim.find_all_by_vin(@vehicle.vin)
      if trims.empty?
        flash[:notice] = vin_error
        new
      else
        @vehicle.save(false)
        redirect_to vehicle_url(:id => @vehicle, 'wizard[step]' => 'trim')
      end
    else
      flash[:notice] = @vehicle.errors.on(:vin)
      new
    end
  end

  def update
    @vehicle = logged_in_user.dealership.all_vehicles.find(params[:id])
    update_success = @vehicle.update_attributes(params[:vehicle]) && @vehicle.save

    if wizard.active?
      case wizard.current_step_name
        when 'trim' then update_trim
        when 'details' then update_details
        when 'add_photos' then update_photos
        when 'summary' then update_summary
      end
    else
      respond_to do |format|
        if update_success
          format.html do
            flash[:notice] = 'Vehicle was successfully updated.'
            redirect_to vehicle_url(@vehicle)
          end

          format.js do
            associate_evd_features_with_vehicle(@vehicle)
            render :partial => 'edit_details_popup',
                               :locals  => {
                                             :vehicle     => @vehicle,
                                             :redraw      => true,
                                             :page_reload => true}
          end
        else
          flash[:notice] = @vehicle.errors.full_messages

          format.html { render :action => "edit" }
          format.js   { render :partial => 'edit_details_popup',
                               :locals  => {
                                             :vehicle => @vehicle,
                                             :redraw => true
                                           } }
        end
      end
    end
  end

  def destroy
    @vehicle = logged_in_user.dealership.all_vehicles.find(params[:id])
    @vehicle.destroy

    respond_to do |format|
      format.html { redirect_to vehicles_url }
      format.xml  { head :ok }
    end
  end

  protected
  def set_navbar_tab
    @current_navbar_tab = 'Inventory'
  end

  def extract_livegrid_params(params)
    params[:user] = logged_in_user

    @want_row_count = (params[:get_total] == 'true')
    @total_rows = @dealership.vehicles.count if @want_row_count
    @offset = params[:offset] || '0'
    @vehicles = Vehicle.paginate(params)
  end

  def update_trim
    if !@vehicle.errors.on(:trim)
      @vehicle.save(false)
      redirect_to vehicle_url(:id => @vehicle, 'wizard[step]' => 'details', 'checkbox_check_standard_feature' => 'yes')
    else
      show
    end
  end

  def update_details
    associate_evd_features_with_vehicle(@vehicle)

    if @vehicle.save
      redirect_to vehicle_url(:id => @vehicle, 'wizard[step]' => 'add_photos')
    else
      flash[:notice] = @vehicle.errors.full_messages
      show
    end
  end

  def update_photos
    redirect_to vehicle_url(:id => @vehicle, 'wizard[step]' => 'summary')
  end

  def update_summary
    @vehicle.update_attribute(:draft, false)
    redirect_to(vehicle_path(@vehicle))
  end

  def associate_evd_features_with_vehicle(vehicle)
    @checkbox_check_standard_feature = !params[:checkbox_check_standard_feature].blank?

    vehicle.features.delete_all
    if params[:evd_features]
      for evd_feature_id in params[:evd_features]
        evd_feature = vehicle.trim.available_features.find_by_id(evd_feature_id)
        vehicle.add_available_feature(evd_feature)
      end
    end
    return true
  end

end
