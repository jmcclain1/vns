class AskEventsController < ApplicationController

  before_filter :set_prospect

  def create
    attributes = {:originator => logged_in_user, :prospect => @prospect}
    attributes.merge!(params[:event])
    AskEvent.create(attributes)

    redirect_to prospect_messages_path(:id => @prospect.id)
  end

  private
  def set_prospect
    @prospect = logged_in_user.dealership.prospects.find(params[:prospect_id])
    raise "Couldn't find prospect #{params[:prospect_id]}" unless @prospect
  end
end
