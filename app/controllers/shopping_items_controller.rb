class ShoppingItemsController < ApplicationController

  before_filter :set_dealership
  before_filter :set_shopping_item, :except => [ :index, :create ]

  def index
    @item = ShoppingItem.new
    @items = @dealership.shopping_items

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @items.to_xml }
    end
  end

  def create

    if params[:item]
      if params[:item][:make_id] == Evd::Make::ANY
        params[:item][:make_id] = nil
        params[:item][:model_id] = nil
      elsif params[:item][:make_id]
        model_param = params["#{params[:item][:make_id]}_model"]
        if model_param.to_i == Evd::Model::ANY
          model_param = nil
        end
        params[:item][:model_id] = model_param
      end
      if params[:item][:min_year]
        if 0 == "any".casecmp(params[:item][:min_year])
          params[:item][:min_year] = nil
        end
      end
      if params[:item][:max_year]
        if 0 == "any".casecmp(params[:item][:max_year])
          params[:item][:max_year] = nil
        end
      end
    end

    attributes = shopping_item_defaults.merge(params[:item] || {})
    @item = ShoppingItem.create(attributes)
    if @item.errors.empty?
      redirect_to shopping_items_path
    else
      @items = @dealership.shopping_items
      render :action => :index
    end
  end

  def update
      if @item.update_attributes(params[:item])
        flash[:notice] = 'Shopping List Item was successfully updated.'
      end

      respond_to do |format|
        format.html { redirect_to shopping_items_path }
        format.xml  { head :ok }
    end
  end

  def destroy
    @item.destroy

    respond_to do |format|
      format.html { redirect_to shopping_items_path }
      format.xml  { head :ok }
    end
  end

  protected
  def set_navbar_tab
    @current_navbar_tab = 'Buying'
  end

  def set_shopping_item
    @item = @dealership.shopping_items.find(params[:id])
  end

  def shopping_item_defaults
    {"originator" => logged_in_user,
     "dealership" => logged_in_user.dealership}
  end

end
