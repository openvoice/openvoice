Openvoice::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  root :to => "user_sessions#new"

  match 'login' => 'user_sessions#new', :as => :login
  match 'logout' => 'user_sessions#destroy', :as => :logout
  match 'signup' => 'users#new', :as => :signup
  match 'activate/:activation_code' => 'users#activate', :as => :activate, :activation_code => nil

  match 'phone_numbers/get_user' => 'phone_numbers#locate_user'
  match 'voicemails/set_transcription' => 'voicemails#set_transcription'
  match 'voicemails/recording' => 'voicemails#recording'
  match 'users/register_phone' => 'users#register_phone'
  match 'logout' => 'user_sessions#destroy'
  match 'incoming_calls/user_menu' => 'incoming_calls#user_menu'
  match 'communications/index' => 'communications#index'
  match 'communications/handle_incoming_call' => 'communications#handle_incoming_call'
  match 'communications/call_screen' => 'communications#call_screen'
  match 'contacts/set_name_recording' => 'contacts#set_name_recording'

  resource :user_session
  resource :account, :controller => "users"
  resources :users do
    member do
      put :suspend
      put :unsuspend
      delete :purge
    end    
    resources :phone_numbers
    resources :voicemails
    resources :messagings
    resources :incoming_calls
    resources :outgoing_calls
    resources :contacts
    resources :profiles
    resources :fs_profiles
  end

end
