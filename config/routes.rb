Hibiki::Application.routes.draw do
  
  resources :users do
    post 'add_to_collection'
    member do
      get 'watchlist'
      get 'collection'
      get 'edit_profile'
      get 'edit_security'
      patch 'update_profile'
      patch 'update_security'
      get 'watchlist_edit'
      patch 'update_watchlist'
    end
  end
  resources :albums do
    collection do
      get :autocomplete_album_namehash
    end
    member do
      get 'albumart', :action => 'album_art'
      get 'tracklist_edit', :action => 'edit_tracklist'
      patch 'tracklist_edit', :action => 'update_tracklist'
      get 'tracklist_export', :action => 'tracklist_export'
      post 'rescrape', action: 'rescrape'
      get 'rescrape', action: 'rescrape'
    end
  end
  resources :sources do
    get :autocomplete_source_namehash, :on => :collection
    member do
      get 'images', :action => 'show_images'
    end
  end
  resources :songs do
    get :autocomplete_song_namehash, :on => :collection
    member do
      get 'images', :action => 'show_images'
    end
  end
  resources :organizations do
    get :autocomplete_organization_namehash, :on => :collection
    member do
      get 'images', :action => 'show_images'
    end
  end
  resources :artists do
    get :autocomplete_artist_namehash, :on => :collection
    member do
      get 'images', :action => 'show_images'
    end
  end
  
  resources :posts do
    member do
      get 'images', :action => 'show_images'
    end
  end
  
  resources :seasons do
    member do
      get 'images', :action => 'show_images'
    end    
  end
  resources :images
  resources :tags
  resources :events
  resources :issues
  match "user_sessions/destroy" => "user_sessions#destroy", via: [:get]
  resource :user_session 

  namespace :maintenance do
    get '/', :action => 'index'
    get 'new_scrape'
    post 'scrape'
    get 'scrape_results'
    get 'generate_urls'
    post 'update_scrape_number'
    
    get 'artist_workqueue'
    get 'source_workqueue'
    get 'organization_workqueue'
    
    get 'update_available_albums'
    
    get 'le_workqueue'
    get 'released_review'
    get 'released_review_drill'
  end  

  root :to => 'pages#front_page'

  #Unique Pages
  get '/login', :to => 'user_sessions#new'
  get '/about', :to => 'pages#info'  
  get '/random_albums', :to => 'pages#random_albums'
  get '/accessdenied', :to => 'pages#access_denied'
  get '/search', :to => 'pages#search'
  get '/changelog', :to => 'pages#changelog'
  get '/calendar', :to => 'pages#calendar'
  get '/help', to: 'pages#help'
  get '/database', to: 'pages#database_landing'
  
  #Scripts
  get '/update_image', :to => 'images#update_image'
  get '/toggle_albums', :to => 'scripts#toggle_albums'
  
  #for password resets
  get '/requestpasswordreset', :to => 'users#requestpasswordreset'
  post '/passwordresetrequest', :to => 'users#passwordresetrequest'
  get '/resetpassword', :to => 'users#resetpassword'
  patch '/passwordreset', :to => 'users#passwordreset'
  
  #Links for js scripts for adding and editing
  get '/add_tag', :to => 'scripts#add_tag'
  get '/remove_tag', :to => 'scripts#remove_tag'
  get '/addreference', :to => 'scripts#add_reference_form'
  get '/addmodel', :to => 'scripts#add_model_form'
  get '/well_toggle', :to => 'scripts#well_toggle'
  
  #links for adding scrape links and albums/artists/sources to posts
  post '/addscrapelink', :to => 'maintenance#addscrapelink'
  
  #User Functions
  post '/watch', :to => 'users#watch'
  post '/unwatch', :to => 'users#unwatch'
  post '/add_to_collection', :to => 'users#add_to_collection'
  post '/uncollect', :to => 'users#uncollect'
  get '/add_grouping', :to => 'users#add_grouping'
    
end
