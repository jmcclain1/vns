module InboxesHelper
  include ApplicationHelper
  include MarkabyHelper

  def make_model_info(listing, path, makemodel_is_link = true)
    markaby do
      div.thumb do
        a :href => path do
          img(:src => "#{listing.vehicle.primary_photo.versions[:small].url}")
        end
      end
      if makemodel_is_link
        link_to "#{listing.vehicle.make_name} #{listing.vehicle.model_name}", path, :class => 'makemodel'
      else
        span.makemodel "#{listing.vehicle.make_name} #{listing.vehicle.model_name}"
      end
      span.vin " VIN: #{listing.vehicle.vin}"
      div.details do
        span.data "#{listing.vehicle.exterior_color.name}"
        span " Int Color: #{listing.vehicle.interior_color.name}"
        br
        span.data "#{listing.dealership.name}"
        span " Location: #{listing.dealership.city}, #{listing.dealership.region}"
      end
    end
  end

  def mileage_column(listing)
    markaby do
      # Nathan, why did we take this out again?
      # Not quite sure.  I don't think I did it, did I?
      # the history of removing this was lost when repository was moved
      span.data listing.vehicle.odometer.to_s
    end
  end

  def price_info(listing)
    markaby do
      span.data listing.asking_price.to_currency
    end
  end

  def as_time(time)
    markaby do
      text time.to_ampm
    end
  end

  def as_date(time)
    markaby do
      text "#{time.strftime('%m/%d/%Y')}"
    end
  end

  def activity_time(date_time)
    markaby do
      b do
        as_time(date_time)
      end
      br
      as_date(date_time)
    end
  end

  def status_messages_info(count_all, count_unread, path)
    markaby do
      p do
        span.messages do
          a :href => path do 
            text pluralize(count_all, "Message")
          end
        end

        if count_all > 0
          text ", "
          if count_unread > 0
            span.data "#{count_unread} Unread"
          else
            span.data "All Read"
          end
        end
      end
    end
  end

  def timing(listing, options)
    markaby do
      case listing.state
      when :expired
        if options[:seller]
          text "Expired"
        else
          text "Ended: No Sale"
        end
      when :canceled
        span.canceled "Canceled"
      when :unstarted
        text "Starts: #{length_of_time_from_now(listing.auction_start)}"
      when :active
        text "Ends: #{length_of_time_from_now(listing.auction_end)}"
      when :completed
        if options[:seller]
          text "Sale complete"
        elsif options [:winner]
          text "Purchase complete"
        else
          text "Auction ended"
        end
      when :pending
        if options[:seller]
          text "Sale pending"
        elsif options[:winner]
          b "You won!"
        else
          text "Auction ended"
        end
      when :relisted
        text "Relisted"
      else
        listing.state.to_s.capitalize
      end
    end
  end

  def high_offer(listing)
    (listing.high_offer.nil? ? 'None' : listing.high_offer.amount.to_currency)
  end

end
