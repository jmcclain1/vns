config.cache_classes = true
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true

# Set default ActionMailer parameters
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
   :default_charset    => 'utf-8',
   :domain             => 'vnscorporation.com',
   :perform_deliveries => true,
   :address            => 'smtp.ey01.engineyard.com',
   :port               => 25 }
