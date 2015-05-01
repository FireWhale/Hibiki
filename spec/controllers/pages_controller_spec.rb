require 'rails_helper'

describe PagesController do
  
  shared_examples "accesses the front page" do |accessible|
    describe 'GET #root' do
      it "populates the albums variable" do
        albums = create_list(:album, 8)
        get :front_page
        expect(assigns(:albums)).to match_array(albums)
      end
      
      it "filters albums by user settings" do
        albums = create_list(:album, 8)
        create(:collection, collected: albums.first, user: @user, relationship: "Ignored")
        @user.update_attribute(:display_bitmask, 57) #Does not display ignored
        get :front_page
        expect(assigns(:albums)).to match_array(albums - [albums.first])
      end
      
      it "populates the posts variable" do
        ability = @user.abilities.sample
        posts = create_list(:post, 3, category: "Blog Post", visibility: ability)
        get :front_page
        expect(assigns(:posts)).to match_array(posts)
      end
      
      it "filters posts by user security" do
        posts = create_list(:post, 5, category: "Blog Post" )
        filtered_posts = posts.select {|item| @user.abilities.include?(item.visibility)}
        get :front_page
        expect(assigns(:posts)).to match_array(filtered_posts)
      end
      
      it "filters posts by blog posts" do
        ability = @user.abilities.sample
        posts = create_list(:post, 5, visibility: ability)
        filtered_posts = posts.select {|item| item.category == "Blog Post"}
        get :front_page
        expect(assigns(:posts)).to match_array(filtered_posts)
      end
      
      it "sorts posts by last created" do
        ability = @user.abilities.sample
        posts = create_list(:post, 3, category: "Blog Post", visibility: ability)
        get :front_page
        expect(assigns(:posts)).to eq(posts.sort_by(&:id).reverse!)        
      end
      
      it "renders the front_page template" do
        get :front_page
        valid_permissions(:front_page, accessible)        
      end
    end
  end
  
  
  shared_examples "accesses the help page" do |accessible|
    describe 'GET #help' do
      it "renders the help template" do
        get :help
        valid_permissions(:help, accessible)        
      end
    end
  end
  
  shared_examples "accesses the calendar" do |accessible|
    describe 'GET #calendar' do
      it "renders the calendar template" do
        get :calendar
        valid_permissions(:calendar, accessible)        
      end
    end
  end
  
  shared_examples "accesses random albums" do |accessible|
    describe 'GET #random_albums' do
      it "accepts count as a param " do
        number = Array(20..50).sample
        create_list(:album, 200)
        get :random_albums, count: number
        expect(assigns(:albums).count).to eq(number)
      end
      
      it "limits count to 250 albums" do
        create_list(:album, 300)
        get :random_albums, count: 600
        expect(assigns(:albums).count).to eq(250)
      end
      
      it "populates an albums variable" do
        albums = create_list(:album, 10)
        get :random_albums
        expect(assigns(:albums)).to match_array(albums)      
      end
      
      it "filters by user_filter_settings" do
        albums = create_list(:album, 10)
        create(:collection, collected: albums.first, user: @user, relationship: "Ignored")
        @user.update_attribute(:display_bitmask, 57) #Does not display ignored      
        get :random_albums
        expect(assigns(:albums)).to match_array(albums - [albums.first])  
      end
      
      it "populates a slice variable" do
        number = Array(20..50).sample
        create_list(:album, number)
        get :random_albums
        expect(assigns(:slice)).to eq(( number / 6.0).ceil)
      end
      
      it "renders the random_albums template" do
        get :random_albums
        valid_permissions(:random_albums, accessible)
      end
      
      it "responds to json" do
        albums = create_list(:album, 5)
        get :random_albums, format: :json
        expect(response.headers['Content-Type']).to match 'application/json'
        #There's really no way to match a order('RAND()') is there
        #Guess we can only look for it and not look at the return
        #which should be @albums as json
      end
    end
  end
  
  shared_examples "can search" do |accessible|
    describe 'GET #search' do
      it "renders the random_albums template" do
        get :search, search: "haha"
        valid_permissions(:search, accessible)
      end
      
      ["album", "artist", "source", "song", "organization"].each do |model|          
        it "populates #{model} total_count" do
          get :search, search: "haha"
          expect(assigns("#{model}_count".to_sym)).to_not be_nil            
        end
      end
        
      it "responds to js" do
        xhr :get, :search, search: "haha", format: :js
        expect(response).to render_template :search
      end
      
    end
  end   
  

  #Authenticate
  before :each do
    activate_authlogic
  end
  
  context 'public access to pages' do
    before :each do
      @user = create(:user, security: "0")
      UserSession.create(@user)
    end
    
    #Shows
    include_examples "accesses the front page", true
    include_examples "accesses the help page", true
    include_examples "accesses the calendar", true
    include_examples "accesses random albums", true
    include_examples "can search", true   
    
  end
  
  context 'user access to pages' do
    before :each do
      @user = create(:user)
      UserSession.create(@user)
    end
        
    #Shows
    include_examples "accesses the front page", true
    include_examples "accesses the help page", true
    include_examples "accesses the calendar", true
    include_examples "accesses random albums", true
    include_examples "can search", true   
    
  end

  context 'admin access to pages' do
    before :each do
      @user = create(:admin)
      UserSession.create(@user)
    end
    
    #Shows
    include_examples "accesses the front page", true
    include_examples "accesses the help page", true
    include_examples "accesses the calendar", true
    include_examples "accesses random albums", true
    include_examples "can search", true   
    
  end
  
  
end


