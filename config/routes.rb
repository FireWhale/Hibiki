Hibiki::Application.routes.draw do

  resources :users do
    member do
      get 'watchlist'
      get 'collection'
      get 'overview'
      get 'edit_profile'
      get 'edit_security'
      get 'edit_watchlist'
      patch 'update_profile'
      patch 'update_security'
      patch 'update_watchlist'
    end
  end
  resources :albums do
    member do
      get 'albumart', :action => 'show_images'
      get 'edit_tracklist'
      post 'update_tracklist'
      patch 'update_tracklist'
      get 'tracklist_export'
      match 'rescrape', action: 'rescrape', via: [:get, :post]
    end
  end
  resources :sources, :songs, :organizations, :artists, :posts, :seasons do
    member {get 'images', :action => 'show_images'}
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

  get '/interactive', to: 'graph#graph'
  get '/interactive_info', to: 'graph#info'

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
  get '/toggle_albums', :to => 'scripts#toggle_albums'
  get '/autocomplete', :to => 'scripts#autocomplete'

  #for password resets
  get '/forgotten_password', :to => 'pages#forgotten_password'
  post '/request_password_reset_email', :to => 'pages#request_password_reset_email'
  get '/reset_password', :to => 'pages#reset_password_page'
  patch '/reset_password', :to => 'pages#reset_password'

  #Links for js scripts for adding and editing
  match '/add_tag' => 'scripts#add_tag', via: [:get, :post]
  match '/remove_tag' => 'scripts#remove_tag', via: [:get, :post]
  get '/add_model', :to => 'scripts#add_model_form'
  get '/well_toggle', :to => 'scripts#well_toggle'

  #User Functions
  match '/watch', :to => 'users#watch', via: [:get, :post]
  match '/unwatch', :to => 'users#unwatch', via: [:get, :post]
  match '/collect', :to => 'users#collect', via: [:get, :post]
  match '/uncollect', :to => 'users#uncollect', via: [:get, :post]
  get '/add_grouping', :to => 'users#add_grouping' #for edit_watchlist

end
