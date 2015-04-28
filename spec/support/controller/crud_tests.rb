require 'rails_helper'

module CrudTests
  #GETS - Showing info
    shared_examples 'has an index page' do |accessible, sort_method|
      model_class = described_class.controller_name.classify.constantize
      model_symbol = model_class.model_name.param_key.to_sym
      
      describe 'GET #index' do
        if accessible == true  
          it "populates a list of #{model_symbol}s" do
            ability = (@user.abilities).sample
            if model_class == Tag || model_class == Issue
              list = create_list(model_symbol, 10, visibility: ability)
            elsif model_class == Post
              list = create_list(model_symbol, 10, visibility: ability, category: "Blog Post", user: @user)
            else
              list = create_list(model_symbol, 10)
            end
            get :index
            expect(assigns("#{model_symbol}s".to_sym)).to match_array list
          end
          
          it "returns a json object" do      
            ability = (@user.abilities).sample
            if model_class == Tag || model_class == Issue
              list = create_list(model_symbol, 10, visibility: ability)
            elsif model_class == Post
              list = create_list(model_symbol, 10, visibility: ability, category: "Blog Post", user: @user)
            elsif model_class == Album
              list = create_list(model_symbol, 10, :with_release_date)
            elsif model_class == Event
              list = create_list(model_symbol, 10, :with_start_date)            
            else
              list = create_list(model_symbol, 10)            
            end
            get :index, format: :json
            expect(response.headers['Content-Type']).to match 'application/json'
            unless model_class == Post
              expect(response.body).to eq(list.sort_by!(&sort_method).to_json)
            else
              expect(response.body).to eq(list.sort_by!(&sort_method).reverse!.to_json)
            end
          end
        
          unless model_class == Tag || model_class == Event || model_class == Season
            it "should call pagination" do
              #This does not test if it's actually paginating.
              #Just the method call. Create another test if you want to eq(list)
              list = create_list(model_symbol, 5)
              expect(model_class).to receive(:page)
              get :index
            end
          end
                 
          it "sorts by #{sort_method}" do
            ability = (@user.abilities).sample
            if model_class == Tag || model_class == Issue
              list = create_list(model_symbol, 10, visibility: ability)
            elsif model_class == Post
              list = create_list(model_symbol, 10, visibility: ability, category: "Blog Post", user: @user)
            elsif model_class == Album
              list = create_list(model_symbol, 10, :with_release_date)
            else
              list = create_list(model_symbol, 10)
            end
            get :index
            unless model_class == Post
              expect(assigns("#{model_symbol}s".to_sym)).to eq(list.sort_by!(&sort_method))   
            else
              expect(assigns("#{model_symbol}s".to_sym)).to eq(list.sort_by!(&sort_method).reverse!)   
            end       
          end
        end
        
        if model_class == Album 
          it "filters out albums with filter_by_user_settings" do
            #create an ignored and set user settings to ignore ignored
            list = create_list(model_symbol, 10)
            create(:collection, album: list.first, user: @user, relationship: "Ignored")
            @user.update_attribute(:display_bitmask, 57) #Does not display ignored
            get :index
            expect(assigns("#{model_symbol}s".to_sym)).to match_array(list - [list.first])
          end
        end
        
        if model_class == Song
          it "filters out albums with filter_by_user_settings" #do
            # list = create_list(model_symbol, 10, :with_album)
            # create(:collection, album: list.first.album, user: @user, relationship: "Ignored")
            # @user.update_attribute(:display_bitmask, 57) #Does not display ignored
            # get :index
            # expect(assigns("#{model_symbol}s".to_sym)).to match_array(list - [list.first])
          # end
          
          it "filters out songs with filter_by_user_settings" #do
            # list = create_list(model_symbol, 10, :with_album)
            #CREATE WHATEVER WILL IGNORE A SONG
            # @user.update_attribute(:display_bitmask, 57) #Does not display ignored
            # get :index
            # expect(assigns("#{model_symbol}s".to_sym)).to match_array(list - [list.first])
              
          # end
       end
        
        if model_class == Tag || model_class == Post || model_class == Issue
          it "filters by security" do
            if model_class == Post
              list = create_list(model_symbol, 10, category: "Blog Post", user: @user)
            else
              list = create_list(model_symbol, 10)
            end
            filtered_list = list.select {|item| @user.abilities.include?(item.visibility)}
            get :index
            expect(assigns("#{model_symbol}s".to_sym)).to match_array filtered_list
          end
        end
        
        if model_class == Issue
          it "filters by status" do
            ability = (@user.abilities).sample
            list = create_list(model_symbol, 10, visibility: ability)
            status = Issue::Status.sample
            filtered_list = list.select { |item| item.status == status}
            get :index, status: status
            expect(assigns("#{model_symbol}s".to_sym)).to match_array filtered_list
          end
          
          it "filters by category" do
            ability = (@user.abilities).sample
            list = create_list(model_symbol, 10, visibility: ability)
            category = Issue::Categories.sample
            filtered_list = list.select { |item| item.category == category}
            get :index, category: category
            expect(assigns("#{model_symbol}s".to_sym)).to match_array filtered_list            
          end
        end
        
        if model_class == Post || model_class == Issue
          it "populates the all_#{model_symbol} instance variable" do
            ability = (@user.abilities).sample
            if model_class == Post
              list = create_list(model_symbol, 10, visibility: ability, category: "Blog Post", user: @user)
            else
              list = create_list(model_symbol, 10, visibility: ability)
            end
            get :index
            expect(assigns("all_#{model_symbol}s".to_sym)).to match_array(list)
          end
        end
        
        if model_class == Post
          it 'filters by tags' do
            ability = (@user.abilities).sample
            list = create_list(model_symbol, 10, :with_tag, visibility: ability, category: "Blog Post", user: @user)
            tag1 = list[0].tags.first
            tag2 = list[1].tags.first
            get :index, tags: [tag1.id, tag2.id]
            expect(assigns("#{model_symbol}s".to_sym)).to match_array(list.first(2))          
          end
          
          it "populates a tags variable" do
            ability = (@user.abilities).sample
            list = create_list(model_symbol, 10, :with_tag, visibility: ability, category: "Blog Post", user: @user)
            tag1 = list[0].tags.first
            tag2 = list[1].tags.first
            get :index, tags: [tag1.id, tag2.id]
            expect(assigns(:tags)).to match_array([tag1, tag2])          
          end
        end
        
        it "renders the :index template" do
          get :index
          valid_permissions(:index, accessible)
        end
      end
    end
    
    shared_examples 'has a show page' do |accessible|
      model_class = described_class.controller_name.classify.constantize
      model_symbol = model_class.model_name.param_key.to_sym
      
      describe 'GET #show' do
        if accessible == true
          it "populates a #{model_symbol} record" do
            record = create(model_symbol)
            get :show, id: record
            expect(assigns(model_symbol)).to eq(record)
          end
          
          it "returns a json object" do
            ability = (@user.abilities).sample
            if model_class == Tag || model_class == Post || model_class == Issue
              record = create(model_symbol, visibility: ability)
            else
              record = create(model_symbol)
            end
            get :show, id: record, format: :json
            expect(response.headers['Content-Type']).to match 'application/json'
            expect(response.body).to eq(record.to_json)
          end
        end
        
        if model_class == Tag || model_class == Post || model_class == Issue
          #These three classes are accessible on a record-to-record basis.
          #It needs custom tests to test for these, obviously. 
          it "renders the :show template if it matches security" do
            ability = (@user.abilities).sample
            record = create(model_symbol, visibility: ability)
            get :show, id: record
            valid_permissions(:show, accessible)
          end
          
          it "does not render the show template if it does not match security" do
            ability = (Ability::Abilities - @user.abilities).sample
            record = create(model_symbol, visibility: ability)
            get :show, id: record
            if @user.abilities.include?("Admin")
              #This is just an unfortunate result of the way admins have
              #access to all templates
              #Might need to restrict it on the controller level for users
              #Currently user restrictions for admins are done at the html level.
              valid_permissions(:show, true)
            else
              valid_permissions(:show, false)
            end
          end

          if model_class == Album || model_class == Song
            it "prepares a credits variable" do
              record = create(model_symbol)
              get :show, id: record
              expect(assigns(:credits)).to be_a(Hash)
            end
          end
          
          if model_class == Album  
            it "prepares an organizations variable"  do
              record = create(model_symbol)
              get :show, id: record
              expect(assigns(:organizations)).to be_a(Hash)
            end
          end
          
          if model_class == Season
            it "populates a sources variable" do
              record = create(model_symbol)
              get :show, id: record
              expect(assigns(:sources)).to be_a(Hash)
            end
          end
        
          if model_class == Artist || model_class == Organization || model_class == Album || model_class == Source || model_class == Song
            it "prepares a related variable" do
              record = create(model_symbol)
              get :show, id: record
              expect(assigns(:related)).to be_a(Hash)
            end
          end
        else
          it "renders the :show template" do
            record = create(model_symbol)
            get :show, id: record
            valid_permissions(:show, accessible)
          end
        end

        
        if model_class == Artist || model_class == Organization || model_class == Source || model_class == Event
          it "assigns an albums variable" do
            record = create(model_symbol, :with_albums)
            get :show, id: record
            expect(assigns(:albums)).to match_array(record.albums)
          end
          
          it "orders the albums by reverse release_date" do
            record = create(model_symbol, :with_albums)
            get :show, id: record
            expect(assigns(:albums).to_ary).to eq(record.albums.sort_by(&:release_date).reverse!)
          end
          
          it "filters albums by filter_by_user_settings" do
            record = create(model_symbol, :with_albums)
            albums = record.albums
            create(:collection, album: albums.first, user: @user, relationship: "Ignored")
            @user.update_attribute(:display_bitmask, 57) #Does not display ignored
            get :show, id: record
            expect(assigns(:albums)).to match_array(albums - [albums.first])
          end
          
          it "paginates albums" do
            #Again, this does not test the pagination is successful
            #Just that page is being called on the albums
            record = create(model_symbol)
            expect(Album).to receive(:page)
            get :show, id: record
          end
          
          it "responds to js" do
            record = create(model_symbol)
            xhr :get, :show, id: record, format: :js
            expect(response).to render_template :show
          end
        end
        

      end
    end
        
  #GETS - Editing info
    shared_examples 'has a new page' do |accessible|
      model_class = described_class.controller_name.classify.constantize
      model_symbol = model_class.model_name.param_key.to_sym
      
      describe 'GET #new' do
        it "assigns a new #{model_symbol} record to @{model_symbol}" do
          get :new
          expect(assigns(model_symbol)).to be_a_new(model_class)
        end
        
        it "returns a json object" do
          get :new, format: :json
          if accessible == true
            expect(response.headers['Content-Type']).to match 'application/json'
            new_record = model_class.new
            new_record.namehash = {} if new_record.respond_to?(:namehash)
            expect(response.body).to eq(new_record.to_json)
          else
            valid_permissions(:new, accessible)
          end
        end
        
        it "renders the :new template" do
          get :new
          valid_permissions(:new, accessible)
        end
      end
    end
    
    shared_examples 'has an edit page' do |accessible|
      model_class = described_class.controller_name.classify.constantize
      model_symbol = model_class.model_name.param_key.to_sym
      
      describe 'GET #edit' do        
        it "populates a #{model_symbol} record" do
          record = create(model_symbol)
          get :edit, id: record
          expect(assigns(model_symbol)).to eq record
        end
        
        it "returns a json object" do
          record = create(model_symbol)
          get :edit, id: record, format: :json
          if accessible == true
            expect(response.headers['Content-Type']).to match 'application/json'
            record.namehash = {} if record.respond_to?(:namehash)
            expect(response.body).to eq(record.to_json)
          else
            valid_permissions(:edit, accessible)
          end          
        end
        
        it "renders the :edit template" do
          record = create(model_symbol)
          get :edit, id: record
          valid_permissions(:edit, accessible)
        end
      end
    end
    
  #POSTS
    shared_examples 'can post create' do |accessible|
      model_class = described_class.controller_name.classify.constantize
      model_symbol = model_class.model_name.param_key.to_sym
      
      describe 'POST #create' do
        if accessible == true    
                
          context "with valid attributes" do
            it "saves the new #{model_symbol}" do
              expect{post :create, model_symbol => attributes_for(model_symbol)}.to change(model_class, :count).by(1)
            end          
            
            it "redirects to show" do
              post :create, model_symbol => attributes_for(model_symbol)
              expect(response).to redirect_to send("#{model_symbol}_path",(assigns[model_symbol]))
            end
            
            it "responds to json" do
              expect{post :create, model_symbol => attributes_for(model_symbol), format: :json}.to change(model_class, :count).by(1)
              expect(response.headers['Content-Type']).to match 'application/json'
              expect(response.body).to eq(model_class.last.to_json)
            end
            
            unless model_class == Issue #issue uses normal create
              it "uses full_save" do
                expect_any_instance_of(model_class).to receive(:full_save)
                post :create, model_symbol => attributes_for(model_symbol)           
              end              
            end
          end
          
          context "with invalid attributes" do
            it "does not save the new #{model_symbol}" do
              expect{post :create, model_symbol => attributes_for(model_symbol, :invalid)}.to change(model_class, :count).by(0)          
            end
            
            it "renders the :new template" do
              post :create, model_symbol => attributes_for(model_symbol, :invalid)
              expect(response).to render_template :new
            end
            
            it "responds to json" do
              post :create, model_symbol => attributes_for(model_symbol, :invalid), format: :json
              expect(response.status).to eq(422) #aka Unprocessable entity
            end
          end
          
        else       
          it "does not save the new #{model_symbol}" do
            expect{post :create, model_symbol => attributes_for(model_symbol)}.to change(model_class, :count).by(0)            
          end  
          
          it "renders the access_denied template" do
            post :create, model_symbol => attributes_for(model_symbol)
            expect(response).to render_template("pages/access_denied")
          end
          
        end     
      end
    end
    
    shared_examples 'can post update' do |accessible, attribute|
      #attribute should be an string attribute that is invalid when blank
      model_class = described_class.controller_name.classify.constantize
      model_symbol = model_class.model_name.param_key.to_sym
      
      describe 'POST #update' do
        let(:record) {create(model_symbol)}
        
        if accessible == true
          it "locates the requested #{model_symbol}" do
            put :update, id: record.id, model_symbol => attributes_for(model_symbol)
            expect(assigns(model_symbol)).to eq(record)
          end
          
          context "with valid attributes" do
            it "updates the #{model_symbol}" do
              put :update, id: record.id, model_symbol => attributes_for(model_symbol, attribute => "valid!")     
              record.reload
              expect(record.send(attribute.to_s)).to eq("valid!")     
            end
            
            it "redirects to the #{model_symbol}" do
              put :update, id: record, model_symbol => attributes_for(model_symbol)
              expect(response).to redirect_to record
            end
            
            it "responds to json" do
              put :update, id: record, model_symbol => attributes_for(model_symbol), format: :json
              expect(response.status).to eq(204) #204 No Content -> ajax success event
            end
            
            unless model_class == Image || model_class == Issue #image/issue just uses normal update_attributes
              it "uses full_update_attributes" do
                expect_any_instance_of(model_class).to receive(:full_update_attributes)
                post :update, id: record.id, model_symbol => attributes_for(model_symbol)
              end
            end
          end
          
          context "with invalid attributes" do       
            #I use a "" string in a field that's validated here
            #I could just use attrbitues_for(model_symbol, :invalide) aka a trait
            #but I'll keep it until it doesn't work. Less modularity here = better tests   
            it "does not update the #{model_symbol}" do
              if model_class == Event
                put :update, id: record.id, model_symbol => attributes_for(model_symbol, attribute => "", shorthand: "")   
              elsif model_class == Post
                put :update, id: record.id, model_symbol => attributes_for(model_symbol, category: "", attribute => "")              
              else
                put :update, id: record.id, model_symbol => attributes_for(model_symbol, attribute => "")   
              end
              record.reload
              expect(record.send(attribute)).to_not eq("")
            end
            
            it "renders the #edit template" do
              if model_class == Event
                put :update, id: record.id, model_symbol => attributes_for(model_symbol, attribute => "", shorthand: "")  
              elsif model_class == Post
                put :update, id: record.id, model_symbol => attributes_for(model_symbol, category: "", attribute => "")              
              else
                put :update, id: record.id, model_symbol => attributes_for(model_symbol, attribute => "")   
              end
              expect(response).to render_template("edit")
            end
            
            it "responds to json" do
              if model_class == Event
                put :update, id: record.id, model_symbol => attributes_for(model_symbol, attribute => "", shorthand: ""), format: :json  
              elsif model_class == Post
                put :update, id: record.id, model_symbol => attributes_for(model_symbol, category: "", attribute => ""), format: :json             
              else
                put :update, id: record.id, model_symbol => attributes_for(model_symbol, attribute => ""), format: :json  
              end              
              expect(response.status).to eq(422) #aka Unprocessable entity
            end
            
          end          
                    
        else
          
          it "does not update the #{model_symbol}" do
            original_value = record.send(attribute.to_s)
            put :update, id: record.id, model_symbol => attributes_for(model_symbol, attribute => "valid!")     
            record.reload
            expect(record.send(attribute.to_s)).to eq(original_value)    
          end
          
          it "redirects to access_denied" do
            put :update, id: record.id, model_symbol => attributes_for(model_symbol)
            expect(response).to render_template("pages/access_denied")
          end
        end

      end
    end
    
    shared_examples 'can delete a record' do |accessible|
      model_class = described_class.controller_name.classify.constantize
      model_symbol = model_class.model_name.param_key.to_sym
      
      
      describe 'DELETE #destroy' do
        
        if accessible == true
          it "destroys the #{model_symbol}" do
            record = create(model_symbol)
            expect{delete :destroy, id: record}.to change(model_class, :count).by(-1)
          end
          
          if model_class == Image
            it "redirects to the record" do
              record = create(model_symbol, :with_imagelist_album)
              album = record.models.first
              delete :destroy, id: record
              expect(response).to redirect_to album           
            end
          else
            it "redirects to #index" do
              record = create(model_symbol)
              delete :destroy, id: record
              expect(response).to redirect_to send("#{model_symbol}s_url")
            end               
          end
     
          it "responds to json" do
            record = create(model_symbol)
            delete :destroy, id: record, format: :json
            expect(response.status).to eq(204)
          end
            
        else
          it "does not destroy the #{model_symbol}" do
            record = create(model_symbol)
            expect{delete :destroy, id: record}.to change(model_class, :count).by(0)
          end
          
          it "redirects to access denied" do
            record = create(model_symbol)
            delete :destroy, id: record
            expect(response).to render_template("pages/access_denied")
          end
          
        end
      end
    end
        
  #Helper Methods  
    def valid_permissions(template, accessible)
      accessible ? (expect(response).to render_template template) : (expect(response).to render_template("pages/access_denied"))
    end
end
