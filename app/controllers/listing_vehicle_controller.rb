class ListingVehicleController < ListingResourceController

  before_filter :set_dealership
  
  CANT_FIND_VEHICLE = "We could not locate that vehicle in our database. Please try again."

  def edit
    find_listing
    render_edit
  end

  def update
    find_listing

    error = nil

    vin = params[:vin]
    stock_number = params[:stock_number]
    if !one_and_only_one(vin, stock_number)
      error = "Please enter either a VIN or a stock number"
    elsif (!vin.blank?)
      if !vin_is_valid?(vin)
        error = vin_validation_error(vin)
      else
        vehicle = Vehicle.find_by_vin(vin)
        if vehicle.nil?
          error = "Unknown VIN"
        end
      end
    else
      vehicle = Vehicle.find_by_stock_number(stock_number)
      if vehicle.nil?
        error = "Unknown stock number"
      end
    end

    if error
      flash[:notice] = error
      render_edit
    else
      @listing.vehicle_id = vehicle.id
      @listing.save(false)
      redirect_to(listing_info_url(@listing))
    end
  end

  protected
  def render_edit
    @drafts = @dealership.draft_listings
    render :template => '/listings/wizard/vehicle'
  end

  def one_and_only_one(a, b)
    (a.blank? && !b.blank?) || (!a.blank? && b.blank?)
  end

  def vin_is_valid?(vin)
    vin_validation_error(vin).nil?
  end

  def vin_validation_error(vin)
    dummy_vehicle = Vehicle.new(:vin => vin)
    dummy_vehicle.valid?
    dummy_vehicle.errors[:vin]
  end

end
