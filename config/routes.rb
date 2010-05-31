ActionController::Routing::Routes.draw do |map|

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  map.root :controller => "user_sessions", :action => "new"

  map.connect 'phone_numbers/get_user', :controller => 'phone_numbers', :action => 'locate_user'
  map.connect 'voicemails/set_transcription', :controller => 'voicemails', :action => 'set_transcription'
  map.connect 'voicemails/recording', :controller => 'voicemails', :action => 'recording'
  map.connect 'users/register_phone', :controller => 'users', :action => 'register_phone'
  map.logout '/logout', :controller => 'user_sessions', :action => 'destroy'
  map.connect 'incoming_calls/user_menu', :controller => 'incoming_calls', :action => 'user_menu'
  map.connect 'communications/handle_incoming_call', :controller => 'communications', :action => 'handle_incoming_call'
  map.connect 'contacts/set_name_recording', :controller => 'contacts', :action => 'set_name_recording'
  map.connect 'contacts/get_name_recording', :controller => 'contacts', :action => 'get_name_recording'

  map.resource :user_session
  map.resource :account, :controller => "users"
  map.resources :users do |user|
    user.resources :phone_numbers
    user.resources :voicemails
    user.resources :messagings
    user.resources :incoming_calls
    user.resources :outgoing_calls
    user.resources :contacts
    user.resources :profiles
  end


  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
