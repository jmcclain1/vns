config.cache_classes = true
config.whiny_nils = true
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = false
config.action_mailer.delivery_method = :test

# For selenium
config.active_record.allow_concurrency = true

POST_LOAD_BLOCKS << lambda do
  silence_warnings do
    Geolocator.default = FakeLocator.new
    ::STORAGE_SERVICE = FakeStorageService.new
  end
end

# Set default ActionMailer parameters
config.action_mailer.default_charset = 'utf-8'
config.action_mailer.perform_deliveries = true
config.action_mailer.raise_delivery_errors = true
config.action_mailer.delivery_method = :test
