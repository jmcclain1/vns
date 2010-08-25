class NotificationMailer < ActionMailer::Base
  helper :email

  def offer_received(offer,options)
    raise 'options[:to] must be specified' unless options[:to]
    @subject        = 'VNS - Offer Received'
    @body[:offer]   = offer
    @recipients     = options[:to]
    @from           = (options[:from] || 'notify@vnscorporation.com')
    @sent_on        = (options[:sent_at] || Time.now)
  end

  def listing_expired(listing,options)
    raise 'options[:to] must be specified' unless options[:to]
    @subject        = 'VNS - Listing Expired'
    @body[:listing] = listing
    @recipients     = options[:to]
    @from           = (options[:from] || 'notify@vnscorporation.com')
    @sent_on        = (options[:sent_at] || Time.now)
  end

  def ask(ask,options)
    raise 'options[:to] must be specified' unless options[:to]
    @subject        = 'VNS - Inquiry Received'
    @body[:ask]     = ask
    @recipients     = options[:to]
    @from           = (options[:from] || 'notify@vnscorporation.com')
    @sent_on        = (options[:sent_at] || Time.now)
  end
  
  def reply(reply,options)
    raise 'options[:to] must be specified' unless options[:to]
    @subject        = 'VNS - Reply Received'
    @body[:reply]     = reply
    @recipients     = options[:to]
    @from           = (options[:from] || 'notify@vnscorporation.com')
    @sent_on        = (options[:sent_at] || Time.now)
  end
  
  def won(won,options)
    raise 'options[:to] must be specified' unless options[:to]
    @subject        = 'VNS - Auction Won'
    @body[:won]     = won
    @recipients     = options[:to]
    @from           = (options[:from] || 'notify@vnscorporation.com')
    @sent_on        = (options[:sent_at] || Time.now)
  end
  
  def lost(lost,options)
    raise 'options[:to] must be specified' unless options[:to]
    @subject        = 'VNS - Auction Lost'
    @body[:lost]    = lost
    @recipients     = options[:to]
    @from           = (options[:from] || 'notify@vnscorporation.com')
    @sent_on        = (options[:sent_at] || Time.now)
  end
  
  def cancel(cancel,options)
    raise 'options[:to] must be specified' unless options[:to]
    @subject        = 'VNS - Auction Cancelled'
    @body[:cancel]  = cancel
    @recipients     = options[:to]
    @from           = (options[:from] || 'notify@vnscorporation.com')
    @sent_on        = (options[:sent_at] || Time.now)
  end
end
