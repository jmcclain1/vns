  resources :password_reset_requests
  resources :user_validation_requests
  resource :terms_of_service
  resources :tos_revisions
  resources :stock_photos
  resources :logins  

  # This should not be necessary, but prevents routing to an action named :id
  connect 'user_validation_requests/:id',
      :controller => 'user_validation_requests',
      :action => 'update',
      :method => 'put'
  

  new_login 'login', :controller => 'logins', :action => 'new',
                     :conditions => { :method => :get }

  logins 'login', :controller => 'logins', :action => 'create',
                  :conditions => { :method => :post }

  logout 'logout', :controller => 'logins', :action => 'destroy',
                   :conditions => { :method => :delete }
  
  resources :users do |user|
    user.resource :password
    user.resource :profile do |profile|
      profile.resource :primary_photo,
        :name_prefix => 'profile_',
        :controller => 'primary_profile_photo'
      profile.resources :photos,
        :name_prefix => 'profile_',
        :controller => 'profile_photos'
    end
  end