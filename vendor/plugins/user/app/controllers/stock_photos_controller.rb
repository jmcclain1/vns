class StockPhotosController < ApplicationController
  before_filter :set_stock_type
  before_filter :hide_if_inactive

  def index
    @photos = stock_type.find(:all)
  end


  def show
    @photo = stock_type.find(params[:id])
  end

  def new
    @photo = stock_type.new
  end

  def create
    @photo = stock_type.new(params[:stock_photo])
    if @photo.save
      flash[:notice] = 'StockPhoto was successfully created.'.customize
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @photo = stock_type.find(params[:id])
  end

  def update
    @photo = stock_type.find(params[:id])
    @photo.attributes = params[:photo]
    if @photo
      flash[:notice] = 'StockPhoto was successfully updated.'.customize
      redirect_to :action => 'show', :id => @photo
    else
      render :action => 'edit'
    end
  end

  def destroy
    Photo.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  def self.stock_types
    [GenericStockPhoto, StockProfilePhoto]
  end

  protected

  def set_stock_type
    @stock_type = params[:stock_type].constantize if params[:stock_type]
  end

  def stock_type
    @stock_type || self.class.stock_types.first
  end

  def hide_if_inactive
    if active?
      return true
    else
      render :text => "This controller has not been activated.  To activate, reopen this controller in your project and override active?() to return true"
      return false
    end
  end

  def active?
    false
  end
end
