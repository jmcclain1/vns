module ListingsHelper
  include InboxesHelper
  include SpotMarketHelper

  def prospect_table(listing)
    markaby do
      td :id => 'potential_buyers' do
        h3 "Potential Buyers"
        table :style => 'width: 100%' do
          tr do
            th :style => 'width: 50%;' do
              a :href => '#' do
                "Name"
              end
            end
            th :style => 'width: 25%;' do
              a :href => '#' do
                "Status"
              end
            end
            th :style => 'width: 25%;' do
              a :href => '#' do
                "Offer"
              end
            end
          end
        end
        if (listing.prospects).empty?
          
          div(:class   => 'buyer_info') do
            span.buyer_name   { em "Buyer List Empty" }
          end # div.buyer_info
          
        end
        for prospect in listing.prospects
          prospect_table_entry(prospect)
        end
      end
    end
  end

  def prospect_table_entry(prospect)
    markaby do
      div(:id      => "prospect_message_#{prospect.to_param}_content_trigger",
          :class   => 'buyer_info',
          :onclick => "new Ajax.Request('#{listing_buyers_path(:id => prospect.listing.id, :buyer_id => prospect.prospector_id)}', {
            method: 'get',
            onSuccess: VNS.PageState.select_message_row(this)
           });") do
 
        if prospect.listing.unread_notifications?(prospect.id, logged_in_user)
          span(:class => 'buyer_name unread',
               :onclick => "new Ajax.Updater(this.removeClassName('unread'));") do
            text "#{prospect.prospector.full_name} (#{prospect.count_events})"
          end
        else
          span.buyer_name   { text "#{prospect.prospector.full_name} (#{prospect.count_events})" }
        end
        # prospect_user = User.find(prospect.prospector_id)
        span.buyer_status { text "TBD " }
        span.buyer_offer  do
          if prospect.active_offer.nil?
            text "None"
          else
            offer_amount(prospect)
          end # if prospect.active_offer.nil?
        end # span.buyer_offer
      end # div.buyer_info
    end
  end
  
  def offer_amount(prospect)
    markaby do
      if prospect.has_high_offer?
        span.high_offer prospect.active_offer.amount.to_currency
      else
        span prospect.active_offer.amount.to_currency
      end
    end
  end

  def prospect_messages(prospect)
    markaby do
      div(:id => "prospect_message_#{prospect.to_param}_content", :style => 'display: none') do

        div.buyer_details do
          h2 "Messages and Offers from #{prospect.prospector.full_name}"
          div.name_dealership do
            text "#{prospect.prospector.full_name}, #{prospect.prospector.dealership.name}"
            br
            span.status "TBD"
          end
        end

        if prospect.listing.pending? && prospect.winner?
          div.complete_sale do
            form_tag("/listings/#{prospect.listing.to_param}/complete_sale", :id => 'complete_sale_form')
            form_btn 'Complete Sale', :onclick => "$('complete_sale_form').submit();"
            end_form_tag
          end
        end

        if !prospect.listing.pending? && !prospect.active_offer.nil?
          div.buyer_active_offer do
            
            div.active_offer do
              h4 "Active Offer:"
              div.offer "#{prospect.active_offer.amount.to_currency}"
            end # div.active_offer
            form_btn "Accept Offer",
            :class   => 'windowshade_form_trigger',
            :onclick => "VNS.FormHelper.toggle_windowshade_form($('spot_market_accept_offer_#{prospect.id}'));"

            br.clear

            div(:id => "spot_market_accept_offer_#{prospect.id}", :class => 'windowshade_form', :style => 'display: none;') do
              render_error_messages(false)
              form_tag(prospect_accept_path(prospect).to_s, :id => "accept_offer_form_#{prospect.id}")
                div.agree_box do
                  check_box_tag("agree_to_terms")
                  text "I accept these conditions"
                end
                text "Comment: "

                text_area_tag 'event[comment]', nil, :size => "60x10", :class => 'comment'
                form_btn 'Cancel',            :onclick => "$('accept_offer_form_#{prospect.id}').reset(); VNS.FormHelper.toggle_windowshade_form($('spot_market_accept_offer_#{prospect.id}'));"
                form_btn 'Accept This Offer', :onclick => "$('accept_offer_form_#{prospect.id}').submit();"
              end_form_tag
              br.clear
            end #div.spot_market_accept_offer
          end # div.buyer_active_offer
        end # if !prospect.active_offer.nil?

        div.action_buttons do
          spot_market_send_message(prospect, 'Seller')
        end # div.action_buttons

        div do
          h4 "History:"
          ul.scrollable_list do
            prospect.events.each { |event|
              history_event_list_item(event, :seller => true)
            }
          end
        end

      end # div.buyer_messages
    end
  end

  def prospect_message_container(listing)
    markaby do
      td :id => 'messages_offers' do
        div(:id => 'active_message_content') do
          for prospect in listing.prospects
            prospect_messages(prospect)
          end
        end
        
        if (listing.prospects).empty?
          listing_prospector_id = 0
        else
          listing_prospector_id = listing.prospects.first.prospector_id
        end
        selected_id = (params[:buyer_id] || (!listing.prospects.empty? && listing.prospects.first.id))
        unless selected_id.nil?
          script "new Ajax.Request('#{listing_buyers_path(:id => listing.id, :buyer_id => listing_prospector_id)}', {
            method: 'get',
            onSuccess: VNS.PageState.select_message_row($('prospect_message_#{selected_id}_content_trigger'))
          });"
        end
      end
    end
  end
end
