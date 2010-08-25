class OfferEventsController < ApplicationController

  before_filter :set_prospect

  def create
    attributes = {:originator => logged_in_user, :prospect => @prospect}
    attributes.merge!(params[:event])
    
    terms_accepted = params[:agree_to_terms]
    if terms_accepted      
      event = OfferEvent.create(attributes)
      if event.errors.empty?
        redirect_to prospect_messages_path(:id => @prospect.id)
      else
        flash[:notice] = event.errors.full_messages
        redirect_to prospect_messages_path(:id => @prospect.id, :panel => 'offer')
      end
    else    
      flash[:notice] = "You must accept the terms"
      redirect_to prospect_messages_path(:id => @prospect.id, :panel => 'offer')
    end
  end

  private
  def set_prospect
    @prospect = logged_in_user.dealership.prospects.find(params[:prospect_id])
    raise "Couldn't find prospect #{params[:prospect_id]}" unless @prospect
  end
end
