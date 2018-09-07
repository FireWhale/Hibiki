require 'rails_helper'

module CrudTests
  #GETS - Showing info
    shared_examples 'has an index page' do |accessible, sort_method|
      model_class = described_class.controller_name.classify.constantize
      model_symbol = model_class.model_name.param_key.to_sym

      describe 'GET #index' do
        if accessible == true
          it "populates a list of #{model_symbol}s" do
            role = @user.nil? ? "Any" : (@user.abilities).sample
            if model_class == Tag || model_class == Issue
              list = create_list(model_symbol, 10, visibility: role)
            elsif model_class == Post
              list = create_list(model_symbol, 10, visibility: role, category: "Blog Post")
            else
              list = create_list(model_symbol, 10)
            end
            get :index
            if model_class == User && @user.nil? == false
              expect(assigns("#{model_symbol}s".to_sym)).to match_array(list + [@user])
            else
              expect(assigns("#{model_symbol}s".to_sym)).to match_array list
            end
          end

          it "returns a json object" do
            ability = @user.nil? ? "Any" : (@user.abilities).sample
            list = create_list(model_symbol, 10)
            get :index, format: :json
            expect(response.headers['Content-Type']).to match 'application/json'
            expect(response).to render_template("#{model_symbol}s/index")
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
            ability = @user.nil? ? "Any" : (@user.abilities).sample
            if model_class == Tag || model_class == Issue
              list = create_list(model_symbol, 10, visibility: ability)
            elsif model_class == Post
              list = create_list(model_symbol, 10, visibility: ability, category: "Blog Post")
            elsif model_class == Album
              list = create_list(model_symbol, 10, :full_attributes)
            elsif model_class == User && @user.nil? == false
              list = create_list(model_symbol, 10) + [@user]
            else
              list = create_list(model_symbol, 10)
            end
            get :index
            unless model_class == Post || model_class == Issue #Posts have newest first
              assigns("#{model_symbol}s".to_sym).to_a.each_cons(2) do |records|
                expect([0,-1]).to include(records[0].send(sort_method) <=> records[1].send(sort_method))
              end
            else
              assigns("#{model_symbol}s".to_sym).to_a.each_cons(2) do |records|
                expect([0,1]).to include(records[0].send(sort_method) <=> records[1].send(sort_method))
              end
            end
          end
        end

        if model_class == Album && @user.nil? == false
          #the method does nothing if the user is nil anyhow
          it "filters out albums with filter_by_user_settings" do
            #create an ignored and set user settings to ignore ignored
            list = create_list(model_symbol, 10)
            create(:collection, collected: list.first, user: @user, relationship: "Ignored")
            @user.update_attribute(:display_bitmask, 57) #Does not display ignored
            get :index
            expect(assigns("#{model_symbol}s".to_sym)).to match_array(list - [list.first])
          end
        end

        if model_class == Song && @user.nil? == false
          #the method does nothing if the user is nil anyhow
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
          it "filters by role" do
            if model_class == Post
              list = create_list(model_symbol, 10, category: "Blog Post")
            else
              list = create_list(model_symbol, 10)
            end
            abilities = @user.nil? ? ["Any"] : @user.abilities
            filtered_list = list.select {|item| abilities.include?(item.visibility)}
            get :index
            expect(assigns("#{model_symbol}s".to_sym)).to match_array filtered_list
          end
        end

        if model_class == Issue
          it "filters by status" do
            ability = @user.nil? ? "Any" : (@user.abilities).sample
            list = create_list(model_symbol, 10, visibility: ability)
            status = Issue::Status.sample
            filtered_list = list.select { |item| item.status == status}
            get :index, params: {status: status}
            expect(assigns("#{model_symbol}s".to_sym)).to match_array filtered_list
          end

          it "filters by category" do
            ability = @user.nil? ? "Any" : (@user.abilities).sample
            list = create_list(model_symbol, 10, visibility: ability)
            category = Issue::Categories.sample
            filtered_list = list.select { |item| item.category == category}
            get :index, params: { category: category}
            expect(assigns("#{model_symbol}s".to_sym)).to match_array filtered_list
          end
        end

        if model_class == Post || model_class == Issue
          it "populates the all_#{model_symbol} instance variable" do
            ability = @user.nil? ? "Any" : (@user.abilities).sample
            if model_class == Post
              list = create_list(model_symbol, 10, visibility: ability, category: "Blog Post")
            else
              list = create_list(model_symbol, 10, visibility: ability)
            end
            get :index
            expect(assigns("all_#{model_symbol}s".to_sym)).to match_array(list)
          end
        end

        if model_class == Post
          it 'filters by tags' do
            ability = @user.nil? ? "Any" : (@user.abilities).sample
            list = create_list(model_symbol, 10, :with_tag, visibility: ability, category: "Blog Post")
            tag1 = list[0].tags.first
            tag2 = list[1].tags.first
            get :index, params: {tags: [tag1.id, tag2.id] }
            expect(assigns("#{model_symbol}s".to_sym)).to match_array(list.first(2))
          end

          it "populates a tags variable" do
            ability = @user.nil? ? "Any" : (@user.abilities).sample
            list = create_list(model_symbol, 10, :with_tag, visibility: ability, category: "Blog Post")
            tag1 = list[0].tags.first
            tag2 = list[1].tags.first
            get :index, params: {tags: [tag1.id, tag2.id]}
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
            get :show, params: {id: record}
            expect(assigns(model_symbol)).to eq(record)
          end

          it "returns a json object" do
            ability = @user.nil? ? "Any" : (@user.abilities).sample
            if model_class == Tag || model_class == Post || model_class == Issue
              record = create(model_symbol, visibility: ability)
            else
              record = create(model_symbol)
            end
            get :show, params: {id: record}, format: :json
            expect(response.headers['Content-Type']).to match 'application/json'
            expect(response).to render_template("#{model_symbol}s/show")
          end

        else
          unless model_class == Image || model_class == Song
            #both of these classes have callbacks that assign the symbol
            #So just remove these from the test. it's kind of a useless test anyhow.
            #more gutcheck than anything.
            it "does not populate a #{model_symbol} record" do
              record = create(model_symbol)
              get :show, params: {id: record}
              expect(assigns(model_symbol)).to be_nil
            end
          end

          it "returns access denied does not populate" do
            record = create(model_symbol)
            get :show, params: {id: record}
            expect(response).to render_template("pages/access_denied")
          end

          it "returns forbidden with json" do
            record = create(model_symbol)
            get :show, params: {id: record}, format: :json
            expect(response.status).to eq(403) #forbidden
          end
        end

        if model_class == Tag || model_class == Post || model_class == Issue
          #These three classes are accessible on a record-to-record basis.
          #It needs custom tests to test for these, obviously.
          it "renders the :show template if it matches role" do
            ability = @user.nil? ? "Any" : (@user.abilities).sample
            record = create(model_symbol, visibility: ability)
            get :show, params: {id: record}
            valid_permissions(:show, accessible)
          end

          it "does not render the show template if it does not match role" do
            abilities = @user.nil? ? ["Any"] : @user.abilities
            ability = (Rails.application.secrets.roles - abilities).sample
            record = create(model_symbol, visibility: ability)
            get :show, params: {id: record}
            if abilities.include?("Admin")
              #This is just an unfortunate result of the way admins have
              #access to all templates
              #Might need to restrict it on the controller level for users
              #Currently user restrictions for admins are done at the html level.
              valid_permissions(:show, true)
            else
              valid_permissions(:show, false)
            end
          end

        elsif model_class == Song
          context 'with an album' do
            it "renders the album" do
              album = create(:album)
              record = create(:song, album: album)
              get :show, params: {id: record}
              expect(response).to redirect_to("/albums/#{album.id}#song-#{record.id}")
            end
          end

          context 'without an album' do
            it "renders the :show template" do
              record = create(model_symbol)
              get :show, params: {id: record}
              expect(response).to render_template("songs/show")
            end
          end
        else
          it "renders the :show template" do
            record = create(model_symbol)
            get :show, params: {id: record}
            valid_permissions(:show, accessible)
          end
        end

        if model_class == Album || model_class == Song
          it "prepares a credits variable" do
            record = create(model_symbol)
            get :show, params: {id: record}
            expect(assigns(:credits)).to be_a(Hash)
          end
        end

        if model_class == Album
          it "prepares an organizations variable"  do
            record = create(model_symbol)
            get :show, params: {id: record}
            expect(assigns(:organizations)).to be_a(Hash)
          end
        end

        if model_class == Season
          it "populates a sources variable" do
            record = create(model_symbol)
            get :show, params: {id: record}
            expect(assigns(:sources)).to be_a(Hash)
          end
        end

        if model_class == Artist || model_class == Organization || model_class == Album || model_class == Source || model_class == Song
          it "prepares a related variable" do
            record = create(model_symbol)
            get :show, params: {id: record}
            expect(assigns(:related)).to be_a(Hash)
          end
        end

        if model_class == Artist || model_class == Organization || model_class == Source || model_class == Event
          it "assigns an albums variable" do
            record = create(model_symbol, :with_albums)
            get :show, params: {id: record}
            expect(assigns(:albums)).to match_array(record.albums)
          end

          it "orders the albums by reverse release_date" do
            record = create(model_symbol, :with_albums)
            get :show, params: {id: record}
            assigns(:albums).to_a.each_cons(2) do |records|
                expect([0,1]).to include(records[0].release_date <=> records[1].release_date)
            end
          end

          unless @user.nil? #handled in model: if user is nil, method does nothing
            it "filters albums by filter_by_user_settings" do
              record = create(model_symbol, :with_albums)
              albums = record.albums
              create(:collection, collected: albums.first, user: @user, relationship: "Ignored")
              @user.update_attribute(:display_bitmask, 57) #Does not display ignored
              get :show, params: {id: record}
              expect(assigns(:albums)).to match_array(albums - [albums.first])
            end
          end

          it "paginates albums" do
            #Again, this does not test the pagination is successful
            #Just that page is being called on the albums
            record = create(model_symbol)
            expect(Album).to receive(:page)
            get :show, params: {id: record}
          end

          it "responds to js" do
            record = create(model_symbol)
            get :show, xhr: true, params: {id: record}, format: :js
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
            expect(response.status).to eq(403) #forbidden
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
          get :edit, params: {id: record}
          expect(assigns(model_symbol)).to eq record
        end

        it "returns a json object" do
          record = create(model_symbol)
          get :edit, params: {id: record}, format: :json
          if accessible == true
            expect(response.headers['Content-Type']).to match 'application/json'
            record.namehash = {} if record.respond_to?(:namehash)
            expect(response.body).to eq(record.to_json)
          else
            expect(response.status).to eq(403) #forbidden
          end
        end

        it "renders the :edit template" do
          record = create(model_symbol)
          get :edit, params: {id: record}
          valid_permissions(:edit, accessible)
        end
      end
    end

  #POSTS
    shared_examples 'can post create' do |accessible|
      model_class = described_class.controller_name.classify.constantize
      model_symbol = model_class.model_name.param_key.to_sym
      model_param_class = described_class.const_get("#{described_class.controller_name.classify}Params")

      describe 'POST #create' do
        if accessible == true

          context "with valid attributes" do
            it "saves the new #{model_symbol}" do
              expect{post :create, params:{model_symbol => attributes_for(model_symbol, :form_input)}}.to change(model_class, :count).by(1)
            end

            it "#{model_param_class.name} to receive filter" do
              expect(model_param_class).to receive(:filter).twice #two because of cancancan
              post :create,params:{model_symbol => attributes_for(model_symbol, :form_input)}
            end

            it "redirects to show" do
              post :create, params:{model_symbol => attributes_for(model_symbol, :form_input)}
              expect(response).to redirect_to send("#{model_symbol}_path",(assigns[model_symbol]))
            end

            it "responds to json" do
              expect{post :create, params:{model_symbol => attributes_for(model_symbol, :form_input)}, format: :json}.to change(model_class, :count).by(1)
              expect(response.headers['Content-Type']).to match 'application/json'
              expect(response.body).to eq(model_class.last.to_json)
            end

            if [Album, Song].include? model_class
              it "calls handle_length_format on params's length attributes" do
                expect_any_instance_of(described_class).to receive(:handle_length_assignment)
                post :create, params:{model_symbol => attributes_for(model_symbol, :form_input)}
              end
            end

            if [Song,Album,Artist,Organization,Source].include? model_class
              it "calls handle_partial_date_assignment on params's date attributes" do
                expect_any_instance_of(described_class).to receive(:handle_partial_date_assignment)
                post :create, params:{model_symbol => attributes_for(model_symbol, :form_input)}
              end
            end
          end

          context "with invalid attributes" do
            it "does not save the new #{model_symbol}" do
              expect{post :create, params:{model_symbol => attributes_for(model_symbol, :invalid)}}.to change(model_class, :count).by(0)
            end

            it "renders the :new template" do
              post :create, params:{model_symbol => attributes_for(model_symbol, :invalid)}
              expect(response).to render_template :new
            end

            it "responds to json" do
              post :create, params:{model_symbol => attributes_for(model_symbol, :invalid)}, format: :json
              expect(response.status).to eq(422) #aka Unprocessable entity /unprocess
            end
          end

        else
          it "does not save the new #{model_symbol}" do
            expect{post :create, params:{model_symbol => attributes_for(model_symbol)}}.to change(model_class, :count).by(0)
          end

          it "renders the access_denied template" do
            post :create, params:{model_symbol => attributes_for(model_symbol)}
            expect(response).to render_template("pages/access_denied")
          end

        end
      end
    end

    shared_examples 'can post update' do |accessible, attribute|
      #attribute should be an string attribute that is invalid when blank
      model_class = described_class.controller_name.classify.constantize
      model_symbol = model_class.model_name.param_key.to_sym
      model_param_class = described_class.const_get("#{described_class.controller_name.classify}Params")

      describe 'POST #update' do
        let(:record) {create(model_symbol)}

        if accessible == true
          it "locates the requested #{model_symbol}" do
            put :update, params: {id: record, model_symbol => attributes_for(model_symbol)}
            expect(assigns(model_symbol)).to eq(record)
          end

          context "with valid attributes" do
            it "updates the #{model_symbol}" do
              put :update, params: {id: record, model_symbol => attributes_for(model_symbol, attribute => "valid!")}
              record.reload
              expect(record.send(attribute.to_s)).to eq("valid!")
            end

            it "redirects to the #{model_symbol}" do
              put :update, params: {id: record, model_symbol => attributes_for(model_symbol)}
              expect(response).to redirect_to record
            end

            it "responds to json" do
              put :update, params: {id: record, model_symbol => attributes_for(model_symbol)}, format: :json
              expect(response.status).to eq(204) #204 No Content no content -> ajax success event
            end

            if [Album, Song].include? model_class
              it "calls handle_length_format on params's length attributes" do
                expect_any_instance_of(described_class).to receive(:handle_length_assignment)
                post(:update, params: {id: record, model_symbol => attributes_for(model_symbol, :form_input)})
              end
            end

            if [Song,Album,Artist,Organization,Source].include? model_class
              it "calls handle_partial_date_assignment on params's date attributes" do
                expect_any_instance_of(described_class).to receive(:handle_partial_date_assignment)
                post(:update, params: {id: record, model_symbol => attributes_for(model_symbol, :form_input)})
              end
            end

          end

          context "with invalid attributes" do
            #I use a "" string in a field that's validated here
            #I could just use attrbitues_for(model_symbol, :invalide) aka a trait
            #but I'll keep it until it doesn't work. Less modularity here = better tests
            it "does not update the #{model_symbol}" do
              if model_class == Event
                put :update, params: {id: record, model_symbol => attributes_for(model_symbol, attribute => "", shorthand: "")}
              elsif model_class == Post
                put :update, params: {id: record, model_symbol => attributes_for(model_symbol, category: "", attribute => "")}
              else
                put :update, params: {id: record, model_symbol => attributes_for(model_symbol, attribute => "")}
              end
              record.reload
              expect(record.send(attribute)).to_not eq("")
            end

            it "renders the #edit template" do
              if model_class == Event
                put :update, params: {id: record, model_symbol => attributes_for(model_symbol, attribute => "", shorthand: "")}
              elsif model_class == Post
                put :update, params: {id: record, model_symbol => attributes_for(model_symbol, category: "", attribute => "")}
              else
                put :update, params: {id: record, model_symbol => attributes_for(model_symbol, attribute => "")}
              end
              expect(response).to render_template("edit")
            end

            it "responds to json" do
              if model_class == Event
                put :update, params: {id: record, model_symbol => attributes_for(model_symbol, attribute => "", shorthand: "")}, format: :json
              elsif model_class == Post
                put :update, params: {id: record, model_symbol => attributes_for(model_symbol, category: "", attribute => "")}, format: :json
              else
                put :update, params: {id: record, model_symbol => attributes_for(model_symbol, attribute => "")}, format: :json
              end
              expect(response.status).to eq(422) #aka Unprocessable entity
            end

          end

        else

          it "does not update the #{model_symbol}" do
            original_value = record.send(attribute.to_s)
            put :update, params: {id: record, model_symbol => attributes_for(model_symbol, attribute => "valid!")}
            record.reload
            expect(record.send(attribute.to_s)).to eq(original_value)
          end

          it "redirects to access_denied" do
            put :update, params: {id: record, model_symbol => attributes_for(model_symbol)}
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
            expect{delete :destroy, params: {id: record}}.to change(model_class, :count).by(-1)
          end

          if model_class == Image
            it "redirects to the record" do
              record = create(model_symbol, :with_imagelist_album)
              album = record.models.first
              delete :destroy, params: {id: record}
              expect(response).to redirect_to album
            end
          else
            it "redirects to #index" do
              record = create(model_symbol)
              delete :destroy, params: {id: record}
              expect(response).to redirect_to send("#{model_symbol}s_url")
            end
          end

          it "responds to json" do
            record = create(model_symbol)
            delete :destroy, params: {id: record}, format: :json
            expect(response.status).to eq(204)
          end

        else
          it "does not destroy the #{model_symbol}" do
            record = create(model_symbol)
            expect{delete :destroy, params: {id: record}}.to change(model_class, :count).by(0)
          end

          it "redirects to access denied" do
            record = create(model_symbol)
            delete :destroy, params: {id: record}
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
