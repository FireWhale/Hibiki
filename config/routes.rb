Hibiki::Application.routes.draw do
  
  resources :users do
    member do
      get 'watchlist'
      get 'collection'
      get 'edit_profile'
      get 'edit_security'
      put 'update_profile'
      put 'update_security'
      get 'watchlist_edit'
      put 'update_watchlist'
    end
  end
  resources :albums do
    collection do
      get :autocomplete_album_namehash
    end
    member do
      get 'albumart', :action => 'album_art'
      get 'tracklist_edit', :action => 'edit_tracklist'
      put 'tracklist_edit', :action => 'update_tracklist'
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
  
  resources :images
  resources :tags
  resources :posts
  resources :events
  resources :seasons
  resources :issues
  match "user_sessions/destroy" => "user_sessions#destroy", via: [:get]
  resource :user_session 

  namespace :maintenance do
    get '/', :action => 'index'
    get 'scrapeanalbum'
    get 'scraperesults'
    post 'scrape'
    get 'new_scrapes'
    post 'update_scrape_number'
    get 'artist_workqueue'
    get 'source_workqueue'
    get 'updated_albums'
    get 'le_workqueue'
    get 'released_review'
    get 'released_review_drill'
  end  

  root :to => 'pages#front_page'

  #Unique Pages
  match '/login', :to => 'user_sessions#new'
  match '/about', :to => 'pages#info'  
  match '/randomalbums', :to => 'pages#randomalbums'
  match '/accessdenied', :to => 'pages#access_denied'
  match '/search', :to => 'pages#search'
  match '/changelog', :to => 'pages#changelog'
  match '/calendar', :to => 'pages#calendar'
  match '/calendarupdate', :to => 'pages#calendar_update'
  match '/graphs', :to => 'pages#graphs'
  
  #Scripts
  match '/updateimage', :to => 'images#updateimage'
  match '/toggle_albums', :to => 'scripts#toggle_albums'
  match '/filter_albums', :to => 'scripts#filter_albums'
  match '/sort_albums', :to => 'scripts#sort_albums'
  
  #for password resets
  get '/requestpasswordreset', :to => 'users#requestpasswordreset'
  post '/passwordresetrequest', :to => 'users#passwordresetrequest'
  get '/resetpassword', :to => 'users#resetpassword'
  put '/passwordreset', :to => 'users#passwordreset'
  
   
  #Links for js scripts for adding and editing
  match '/addtag', :to => 'tags#add_tag'
  match '/removetag', :to => 'tags#remove_tag'
  match '/addartistforsong', :to => 'artists#addartistforsongform'
  match '/addsourceforseason', :to => 'sources#addsourceforseasonform'
  match '/addsourceforsong', :to => 'sources#addsourceforsongform'
  match '/addreference', :to => 'scripts#add_reference_form'
  match '/addmodel', :to => 'scripts#add_model_form'
  match '/well_toggle', :to => 'scripts#well_toggle'
  
  #links for adding scrape links and albums/artists/sources to posts
  match '/addscrapelink', :to => 'maintenance#addscrapelink'
  match '/addtopost', :to => 'posts#addtopost'
  
  #Index js scripts
  match '/album_preview', :to => 'albums#album_preview'
  match '/songpreview', :to => 'songs#songpreview'
  match '/songpreviewhide', :to => 'songs#songpreviewhide'
  
  
  #User Functions
  match '/watch', :to => 'users#watch'
  match '/unwatch', :to => 'users#unwatch'
  match '/add_to_collection', :to => 'users#add_to_collection'
  match '/uncollect', :to => 'users#uncollect'
  match '/add_grouping', :to => 'users#add_grouping'
    
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
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
