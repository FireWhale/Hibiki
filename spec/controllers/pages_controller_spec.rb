require 'rails_helper'

describe PagesController do
  
  shared_examples "accesses the front page" do |accessible|
    describe 'GET #root' do
      it "populates the albums variable" do
        albums = create_list(:album, 8)
        get :front_page
        expect(assigns(:albums)).to match_array(albums)
      end
      
      unless @user.nil? #handled in model. method with nil user does nothing
        it "filters albums by user settings" do
          albums = create_list(:album, 8)
          create(:collection, collected: albums.first, user: @user, relationship: "Ignored")
          @user.update_attribute(:display_bitmask, 57) #Does not display ignored
          get :front_page
          expect(assigns(:albums)).to match_array(albums - [albums.first])
        end
      end
      
      it "populates the posts variable" do
        ability = @user.nil? ? "Any" : (@user.abilities).sample
        posts = create_list(:post, 3, category: "Blog Post", visibility: ability)
        get :front_page
        expect(assigns(:posts)).to match_array(posts)
      end
      
      it "filters posts by user security" do
        abilities = @user.nil? ? ["Any"] : @user.abilities
        posts = create_list(:post, 5, category: "Blog Post" )
        filtered_posts = posts.select {|item| abilities.include?(item.visibility)}
        get :front_page
        expect(assigns(:posts)).to match_array(filtered_posts)
      end
      
      it "filters posts by blog posts" do
        ability = @user.nil? ? "Any" : (@user.abilities).sample
        posts = create_list(:post, 5, visibility: ability)
        filtered_posts = posts.select {|item| item.category == "Blog Post"}
        get :front_page
        expect(assigns(:posts)).to match_array(filtered_posts)
      end
      
      it "sorts posts by last created" do
        ability = @user.nil? ? "Any" : (@user.abilities).sample
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
      
      unless @user.nil? #handled in model. method with nil user does nothing
        it "filters by user_filter_settings" do
          albums = create_list(:album, 10)
          create(:collection, collected: albums.first, user: @user, relationship: "Ignored")
          @user.update_attribute(:display_bitmask, 57) #Does not display ignored      
          get :random_albums
          expect(assigns(:albums)).to match_array(albums - [albums.first])  
        end
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
  
  shared_examples 'can reset passwords' do |accessible|
    describe 'resets passwords' do
      #4 methods in this example group:
      #Get forgotten password
      #Post send password reset email
      #Get reset_password_page
      #post reset_password
      
      describe 'GET #forgotten_password' do
        it "renders the forgotten_password template" do
          get :forgotten_password
          valid_permissions(:forgotten_password, accessible)
        end
      end
      
      describe 'POST request_password_reset_email' do
        if accessible == true          
          it "renders forgotten_password" do
            post :request_password_reset_email
            expect(response).to redirect_to forgotten_password_path
          end
          
          it "returns #200 with json" do
            post :request_password_reset_email, format: :json
            expect(response.status).to eq(204) #204 No Content -> ajax success event
          end
          
          context "with valid email" do
            let(:user) {create(:user)}
            
            it "locates the user" do
              post :request_password_reset_email, email: user.email
              expect(assigns(:user)).to eq(user)
            end
                        
            it "sends off an email" do
              expect{post :request_password_reset_email, email: user.email}.to change(ActionMailer::Base.deliveries, :count).by(1)
            end
            
            it "uses the deliver_password_reset_instructions! method" do
              expect_any_instance_of(User).to receive(:deliver_password_reset_instructions!)
              post :request_password_reset_email, email: user.email
            end
          end
          
          context "without valid email" do
            it "does not send off an email" do
              expect{post :request_password_reset_email, email: "fake@email.com"}.to change(ActionMailer::Base.deliveries, :count).by(0)              
            end
          end
          
        else
          it "renders access_denied" do
            post :request_password_reset_email
            expect(response).to render_template("pages/access_denied")
          end
                    
          it "does not send off an email" do
            user = create(:user)
            expect{post :request_password_reset_email, email: user.email}.to change(ActionMailer::Base.deliveries, :count).by(0)              
          end
        end
      end
      
      describe 'GET #reset_password_page' do
        it "renders the reset_password_page" do
          get :reset_password_page
          valid_permissions(:reset_password_page, accessible)
        end
        if accessible == true
          context 'with valid token' do
            it "finds and assigns a user" do
              user = create(:user)
              user.reset_perishable_token!
              get :reset_password_page, token: user.perishable_token
              expect(assigns(:user)).to eq(user)
            end
          end
          
          context 'without valid token' do
            it "does not assign @user" do
              get :reset_password_page
              expect(assigns(:user)).to be_nil
            end
          end          
        else
          it "does not find or assign a user even with a valid token" do
            user = create(:user)
            user.reset_perishable_token!
            get :reset_password_page, token: user.perishable_token
            expect(assigns(:user)).to be_nil
          end
        end

      end
      
      describe 'POST #reset_password' do
        if accessible == true
          context "with valid token" do
            context "with valid password" do
              let(:user) {create(:user)}
              
              before(:each) do
                user.reset_perishable_token!
              end
              
              it "assigns a user" do
                post :reset_password, user: {:token => user.perishable_token, password: "hahapass44", password_confirmation: "hahapass44"}
                expect(assigns(:user)).to eq(user)        
              end
              
              it "changes the password" do
                post :reset_password, user: {:token => user.perishable_token, password: "hahapass44", password_confirmation: "hahapass44"}
                expect(user.reload.valid_password?("hahapass44")).to eq(true)
              end
              
              it "redirects to root" do
                post :reset_password, user: {:token => user.perishable_token, password: "hahapass44", password_confirmation: "hahapass44"}
                expect(response).to redirect_to(:root)
              end
              
              it "responds to json" do
                post :reset_password, user: {:token => user.perishable_token, password: "hahapass44", password_confirmation: "hahapass44"}, format: :json
                expect(response.status).to eq(204) #204 No Content no content -> ajax success event
              end
              
            end
            
            context "without valid password" do
              let(:user) {create(:user)}
              
              before(:each) do
                user.reset_perishable_token!
              end
              
              it "assigns user" do
                post :reset_password, user: {:token => user.perishable_token}
                expect(assigns(:user)).to eq(user)               
              end
              
              it "assigns a token" do
                post :reset_password, user: {:token => user.perishable_token}
                expect(assigns(:token)).to eq(user.perishable_token)               
              end
              
              it "renders reset_password_path again" do
                post :reset_password, user: {:token => user.perishable_token}
                expect(response).to render_template :reset_password_page
              end
              
              it "renders user errors as json" do
                post :reset_password, user: {:token => user.perishable_token}, format: :json
                expect(response.body).to eq(assigns(:user).errors.to_hash.except!(:crypted_password, :password_salt).to_json)
              end
              
              it "has unprocessable entity as json" do
                post :reset_password, user: {:token => user.perishable_token}, format: :json
                expect(response.status).to eq(422) #aka Unprocessable entity /unprocess
              end
            end
          end
          
          context "without valid token" do
            it "redirects to root" do
              post :reset_password, user: {:token => "well"}
              expect(response).to redirect_to(:root)
            end
            
            it "renders unprocessable_entity with json" do
              post :reset_password, user: {:token => "well"}, format: :json
              expect(response.status).to eq(422) #aka Unprocessable entity /unprocess
            end
            
            it "does not assign a user" do
              post :reset_password, user: {:token => "well"}
              expect(assigns(:user)).to be_nil
            end
          end    
        else      
          it "renders access denied" do
            post :reset_password
            expect(response).to render_template("pages/access_denied")
          end
          
          it "renders forbidden as json" do
            post :reset_password, format: :json
            expect(response.status).to eq(403) #forbidden
          end
        end
      end
    end
  end

  #Authenticate
  before :each do
    activate_authlogic
  end
  
  context 'public access to pages' do
    
    #Shows
    include_examples "accesses the front page", true
    include_examples "accesses the help page", true
    include_examples "accesses the calendar", true
    include_examples "accesses random albums", true
    include_examples "can search", true   
    
    #Reset Password
    include_examples "can reset passwords", true
    
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
    
    #Reset Password
    include_examples "can reset passwords", false
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
    
    #Reset Password
    include_examples "can reset passwords", true
  end
  
  
end


