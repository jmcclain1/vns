module SpotMarketHelper
  include MarkabyHelper

  def history_event_list_item(event, options = {:seller => false})
    markaby do
      li(:class => event[:type].underscore) do
        div.message_header do
          text history_event_text(event,options)
        end
        div.message_body { event.comment unless event.comment.nil? }
      end
    end
  end

  def history_event_text(event,options)
    event_originator_full_name = (event.originator.id == logged_in_user.id)? "You" : event.originator.full_name
    
    case event[:type]
      when 'AskEvent'
        "#{event_originator_full_name} wrote:"
      when 'CancelEvent'
        "#{event_originator_full_name} cancelled this listing"
      when 'LostEvent'
        if options[:seller]
          "You accepted an offer from another buyer"
        else
          "Vehicle sold (you didn't win)"
        end
      when 'OfferEvent'
        "#{event_originator_full_name} offered: #{event.amount.to_currency}"
      when 'ReplyEvent'
        "#{event_originator_full_name} wrote:"
      when 'WonEvent'
        if options[:seller]
          "Offer Accepted"
        else
          "You Won! according to #{event_originator_full_name}"
        end
      when 'NewListingEvent'
        if options[:seller]
          "You sent this listing to your partner"
        else
          "#{event_originator_full_name} sent you this listing"
        end
      when 'ShoppingItemEvent'
        if options[:seller]
          "Buyer is watching this listing"  # should go away
        else
          "This listing matches an item in your shopping list"
        end
    end
  end

  def spot_market_seller_info(prospect)
    markaby do
      div(:id => 'spot_market_seller_info', :class => 'section') do
        b "#{prospect.listing.lister.full_name}"
        text ", #{prospect.listing.lister.dealership.name}"
      end
    end
  end

  def spot_market_active_offer(prospect)
    markaby do
      unless prospect.active_offer.nil?
        div(:id => 'spot_market_active_offer', :class => 'section') do
          if prospect.listing.pending? && prospect.listing.winning_prospect == prospect
            strong "My accepted offer Details: #{prospect.active_offer.amount.to_currency}"
          else
            strong "My current offer Details: #{prospect.active_offer.amount.to_currency}"
          end
        end
      end
    end
  end

  def offer_button_label(prospect)
    (prospect.active_offer.nil? ? "Make Offer" : "Improve Offer")
  end
  
  def spot_market_send_offer(prospect)
    button_label = offer_button_label(prospect)

    markaby do
      if prospect.listing.pending?
        if prospect.listing.winning_prospect == prospect
          div(:class => 'section') do
            strong "Waiting for seller to complete sale."
          end
        end
      else
        form_btn button_label, :class => 'windowshade_form_trigger', :onclick => "VNS.FormHelper.toggle_windowshade_form($('spot_market_send_offer_#{prospect.id}'));"

        div(:id => "spot_market_send_offer_#{prospect.id}", :class => 'windowshade_form', :style => 'display: none;') do
          form_tag(prospect_offer_path(prospect).to_s, {:id => "spot_market_send_offer_form_#{prospect.id}"})
            h4 "Compose Offer to #{prospect.listing.lister.full_name}"
            render_error_messages

            fieldset.fields do
              div do
                label "Offer"
                text  "$ "
                text_field_tag 'event[amount]', "Enter Offer Price", :size => "15"
              end

              div do
                label "Message"
                text_area_tag 'event[comment]', nil, :size => "60x10"
              end    
                          
              div.agree_box do
                  check_box_tag("agree_to_terms")
                  text "I accept these conditions"
              end
            end

            fieldset(:class => 'buttons', :style => 'float: right;') do
              form_btn 'Submit Offer', :onclick => "$('spot_market_send_offer_form_#{prospect.id}').submit();"
              form_btn 'Clear',        :onclick => "$('spot_market_send_offer_form_#{prospect.id}').reset();"
              form_btn 'Cancel',       :onclick => "$('spot_market_send_offer_form_#{prospect.id}').reset(); VNS.FormHelper.toggle_windowshade_form($('spot_market_send_offer_#{prospect.id}'));"
            end
          end_form_tag
        end
      end

    end
  end

  def spot_market_send_message(prospect, actor)
    markaby do
      form_btn "Send Message",
        :class   => 'windowshade_form_trigger',
        :onclick => "VNS.FormHelper.toggle_windowshade_form($('spot_market_send_message_#{prospect.id}'));$('event[comment]').focus();"

      div(:id => "spot_market_send_message_#{prospect.id}", :class => 'windowshade_form send_message_form', :style => 'display: none;') do
        form(:method => 'post', :id => "spot_market_send_message_form_#{prospect.id}", :action => actor == 'Buyer' ? prospect_ask_path(prospect) : prospect_reply_path(prospect)) do

          h4 "Compose Message to #{actor == 'Buyer' ? prospect.listing.lister.full_name : prospect.prospector.full_name}"

          fieldset.fields do
            label "Message"
            text_area_tag 'event[comment]', nil, :size => "60x10"
          end

          fieldset(:class => 'buttons', :style => 'float: right;') do
            form_btn 'Submit Message', :onclick => "$('spot_market_send_message_form_#{prospect.id}').submit();"
            form_btn 'Cancel',         :onclick => "$('spot_market_send_message_form_#{prospect.id}').reset(); VNS.FormHelper.toggle_windowshade_form($('spot_market_send_message_#{prospect.id}'));"
          end
        end
      end

      div.clear { }
    end
  end

  def spot_market_event_history(prospect)
    markaby do
      div(:id => 'spot_market_event_history') do
        ul.scrollable_list do
          prospect.events.each { |event|
            history_event_list_item(event)
          }
        end
      end
    end
  end
end
