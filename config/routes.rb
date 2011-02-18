Openvoice::Application.routes.draw do

  root :to => "user_sessions#new"

  match 'login'  => 'user_sessions#new', :as => :login
  match 'logout' => 'user_sessions#destroy', :as => :logout
  match 'signup' => 'users#new', :as => :signup
  match 'activate/:activation_code' => 'users#activate', :as => :activate, :activation_code => nil

  match 'phone_numbers/get_user'       => 'phone_numbers#locate_user'

  match 'voicemails/set_transcription' => 'voicemails#set_transcription'
  match 'voicemails/recording'         => 'voicemails#recording'
  match 'voicemails/create'            => 'voicemails#create'
  
  match 'users/register_phone'         => 'users#register_phone'

  match 'incoming_calls/user_menu'     => 'incoming_calls#user_menu'

  match 'communications/index'         => 'communications#index'
  match 'communications/handle_incoming_call' => 'communications#handle_incoming_call'
  match 'communications/call_screen'   => 'communications#call_screen'

  match 'contacts/set_name_recording'  => 'contacts#set_name_recording'

  match 'messagings/create'       => 'messagings#create'
  match 'messagings/tropo_create' => 'messagings#tropo_create'

  resource :user_session
  resource :account, :controller => "users"

  resources :users do
    member do
      put :suspend
      put :unsuspend
      delete :purge
    end    
    resources :phone_numbers do
      collection do
        post :update_attribute_on_the_spot
      end
    end
    resources :voicemails
    resources :messagings do
      get :autocomplete_contact_name, :on => :collection
    end
    resources :incoming_calls
    resources :outgoing_calls do
      get :autocomplete_contact_name, :on => :collection      
    end
    resources :contacts do
      collection do
        post :update_attribute_on_the_spot
      end      
    end
    resources :profiles
    resources :fs_profiles
  end

end
