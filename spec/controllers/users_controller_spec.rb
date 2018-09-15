require 'rails_helper'

describe UsersController do
  include_examples "global controller tests" #Global Tests

  #DON'T DELETE UNTIL TEST IS ADDED
  #test the post update_profile to make sure no one, not even admins
  #can post to a different user. The GETS are already filtered out for admins
  #in the HTML, but the posts still need to be filtered out, maybe at the controller
  #level such as:
  #@user = User.find(params[:id])
  #if current_user == @user
  #do stuff
  #end

  #Javascript
    shared_examples "can collect/uncollect" do |accessible|
      describe 'POST #collect' do
       if accessible == true
          it "responds to html" do
            record = create(:album)
            get :collect, params: {record_type: record.class.to_s, record_id: record.id, relationship: "Collected"}
            expect(response).to redirect_to record
          end

          it "responds to js" do
            record = create(:album)
            post :collect, xhr: true, params: {record_type: record.class.to_s, record_id: record.id}
            expect(response).to render_template(:collect)
          end

          context "with valid params" do
            it "creates a collection" do
              record = create(:album)
              expect{get :collect, params: {record_type: record.class.to_s, record_id: record.id, relationship: "Collected"}}.to change(Collection, :count).by(1)
            end

            it "assigns @record" do
              record = create(:song)
              get :collect, params: {record_type: record.class.to_s, record_id: record.id, relationship: "Collected"}
              expect(assigns(:record)).to eq(record)
            end
          end

          context "without valid params" do
            it "does not create a collection" do
              record = create(:song)
              expect{get :collect, params: {record_type: record.class.to_s, record_id: record.id}}.to change(Collection,:count).by(0)
            end
          end
        else
          it "renders access denied" do
            get :collect
            expect(response).to render_template("pages/access_denied")
          end

          it "gives forbidden with js" do
            post :collect, xhr: true, format: :js
            expect(response.status).to eq(403) #forbidden
          end
        end
      end

      describe 'POST #uncollect' do
        if accessible == true
          it "responds to html" do
            record = create(:album)
            create(:collection, user: @user, collected: record)
            get :uncollect, params: {record_type: record.class.to_s, record_id: record.id}
            expect(response).to redirect_to record
          end

          it "responds to js" do
            record = create(:album)
            create(:collection, user: @user, collected: record)
            post :uncollect, xhr: true, params: {record_type: record.class.to_s, record_id: record.id}
            expect(response).to render_template(:uncollect)
          end

          context "with valid params" do
            it "destroys a collection" do
              record = create(:album)
              create(:collection, user: @user, collected: record)
              expect{post :uncollect, xhr: true, params: {record_type: record.class.to_s, record_id: record.id}}.to change(Collection,:count).by(-1)
            end

            it "assigns a record" do
              record = create(:album)
              create(:collection, user: @user, collected: record)
              post :uncollect, xhr: true, params: {record_type: record.class.to_s, record_id: record.id}
              expect(assigns(:record)).to eq(record)
            end
          end

          context "without valid params" do
            it "does not destroy a collection" do
              record = create(:album)
              create(:collection, user: @user, collected: record)
              expect{post :uncollect, xhr: true, params: {record_type: "Artist", record_id: record.id}}.to change(Collection,:count).by(0)
            end
          end
        else
          it "renders access denied" do
            get :uncollect
            expect(response).to render_template("pages/access_denied")
          end

          it "gives forbidden with js" do
            post :uncollect, xhr: true, format: :js
            expect(response.status).to eq(403) #forbidden
          end
        end
      end
    end

    shared_examples "can watch/unwatch" do |accessible|
      describe 'POST #watch' do
        if accessible == true
          it "responds to html" do
            record = create(:artist)
            get :watch, params: {watched_type: record.class.to_s, watched_id: record.id}
            expect(response).to redirect_to record
          end

          it "responds to js" do
            record = create(:organization)
            post :watch, xhr: true, params: {watched_type: record.class.to_s, watched_id: record.id}
            expect(response).to render_template(:watch)
          end

          context "with valid params" do
            it "creates a collection" do
              record = create(:source)
              expect{get :watch, params: {watched_type: record.class.to_s, watched_id: record.id}}.to change(Watchlist, :count).by(1)
            end

            it "assigns @record" do
              record = create(:organization)
              get :watch, params: {watched_type: record.class.to_s, watched_id: record.id}
              expect(assigns(:watched)).to eq(record)
            end
          end

          context "without valid params" do
            it "does not create a collection" do
              record = create(:source)
              expect{get :watch, params: {watched_type: "Song", watched_id: record.id}}.to change(Watchlist,:count).by(0)
            end
          end
        else
          it "renders access denied" do
            get :watch
            expect(response).to render_template("pages/access_denied")
          end

          it "gives forbidden with js" do
            post :watch, xhr: true, format: :js
            expect(response.status).to eq(403) #forbidden
          end
        end
      end

      describe 'POST #unwatch' do
        if accessible == true
          it "responds to html" do
            record = create(:artist)
            create(:watchlist, user: @user, watched: record)
            get :unwatch, params: {watched_type: record.class.to_s, watched_id: record.id}
            expect(response).to redirect_to record
          end

          it "responds to js" do
            record = create(:source)
            create(:watchlist, user: @user, watched: record)
            post :unwatch, xhr: true, params: {watched_type: record.class.to_s, watched_id: record.id}
            expect(response).to render_template(:unwatch)
          end

          context "with valid params" do
            it "destroys a collection" do
              record = create(:organization)
              create(:watchlist, user: @user, watched: record)
              expect{post :unwatch, xhr: true, params: {watched_type: record.class.to_s, watched_id: record.id}}.to change(Watchlist,:count).by(-1)
            end

            it "assigns a record" do
              record = create(:artist)
              create(:watchlist, user: @user, watched: record)
              post :unwatch, xhr:true, params: {watched_type: record.class.to_s, watched_id: record.id}
              expect(assigns(:watched)).to eq(record)
            end
          end

          context "without valid params" do
            it "does not destroy a collection" do
              record = create(:source)
              create(:watchlist, user: @user, watched: record)
              expect{post :unwatch, xhr: true, params: {watched_type: "Song", watched_id: record.id}}.to change(Watchlist,:count).by(0)
            end
          end
        else
          it "renders access denied" do
            get :unwatch
            expect(response).to render_template("pages/access_denied")
          end

          it "gives forbidden with js" do
            post :unwatch, xhr: true, format: :js
            expect(response.status).to eq(403) #forbidden
          end
        end
      end
    end


  #Shows
    shared_examples "has a user show page" do |accessible|
      describe 'GET #show' do
        if accessible == true
          context 'with a public user' do
            let(:user) { create(:user)}

            before(:each) do
              user.update_attributes(:privacy => 4) #show profile
            end

            it "populates a user record" do
              get :show, params: {id: user}
              expect(assigns(:user)).to eq(user)
            end

            it "renders the show template" do
              get :show, params: {id: user}
              expect(response).to render_template(:show)
            end

            it "returns a json object" do
              get :show, params: {id: user}, format: :json
              expect(response.headers['Content-Type']).to match 'application/json'
              expect(response.body).to eq(user.to_json)
            end
          end

          context 'with a shy user' do
            let(:user) { create(:user)}

            before(:each) do
              user.update_attributes(:privacy => 3) #show watch and show col
            end

            it "populates a user record" do
              get :show, params: {id: user}
              expect(assigns(:user)).to eq(user)
            end

            it "renders the private_page template" do
              get :show, params: {id: user}
              expect(response).to render_template(:private_page)
            end

            it "returns forbidden with json" do
              get :show, params: {id: user}, format: :json
              expect(response.status).to eq(403) #forbidden
            end
          end

          unless @user.nil?
            context "with the user's user" do
              it "populates a user record" do
                get :show, id: @user
                expect(assigns(:user)).to eq(@user)
              end

              it "renders the show template" do
                get :show, id: @user
                expect(response).to render_template(:show)
              end

              it "returns a json object" do
                get :show, id: @user, format: :json
                expect(response.headers['Content-Type']).to match 'application/json'
                expect(response.body).to eq(@user.to_json)
              end
            end
          end

        else
          it "does not assign a user" do
            user = create(:user)
            get :show, params: {id: user}
            expect(assigns(:user)).to be_nil
          end

          it "renders access denied" do
            user = create(:user)
            get :show, params: {id: user}
            expect(response).to render_template("pages/access_denied")
          end
        end
      end
    end

    shared_examples "has an overview page" do |accessible|
      describe 'GET #overview' do
        let(:user) {create(:user)}
        if accessible == true
          it "has an overview page" do
            get :overview, params: {id: user}
            expect(response).to render_template(:overview)
          end

          it "assigns a user" do
            get :overview, params: {id: user}
            expect(assigns(:user)).to eq(user)
          end

          it "responds to json" do
            get :overview, params: {id: user}, format: :json
            expect(response.headers['Content-Type']).to match 'application/json'
            expect(response.body).to eq(user.to_json)
          end
        else
          it "renders access denied" do
            user = create(:user)
            get :overview, params: {id: user}
            expect(response).to render_template("pages/access_denied")
          end
        end
      end
    end

    shared_examples "can get a watchlist" do |accessible|
      describe 'GET #watchlist' do
        if accessible == true
          context 'with a public user' do
            let(:user) { create(:user, :with_multiple_watchlists)}

            before(:each) do
              user.update_attributes(:privacy => 1) #show watchlist
            end

            it "populates a user variable" do
              get :watchlist, params: {id: user}
              expect(assigns(:user)).to eq(user)
            end

            it "populates a watched variable" do
              get :watchlist, params: {id: user}
              expect(assigns(:watched)).to be_a Hash
            end

            it "renders the watchlist template" do
              get :watchlist, params: {id: user}
              expect(response).to render_template(:watchlist)
            end

            it "returns a json object" do
              get :watchlist, params: {id: user}, format: :json
              expect(response.headers['Content-Type']).to match 'application/json'
              expect(response.body).to eq(user.watchlists.map(&:watched).to_json)
            end
          end

          context 'with a shy user' do
            let(:user) { create(:user)}

            before(:each) do
              user.update_attributes(:privacy => 6) #show profile and show col
            end

            it "populates a user record" do
              get :watchlist, params: {id: user}
              expect(assigns(:user)).to eq(user)
            end

            it "renders the private_page template" do
              get :watchlist, params: {id: user}
              expect(response).to render_template(:private_page)
            end

            it "returns forbidden with json" do
              get :watchlist, params: {id: user}, format: :json
              expect(response.status).to eq(403) #forbidden
            end
          end

          unless @user.nil?
            context "with the user's user" do
              it "populates a user variable" do
                get :watchlist, id: @user
                expect(assigns(:user)).to eq(@user)
              end

              it "populates a watched variable" do
                get :watchlist, id: @user
                expect(assigns(:watched)).to be_a Hash
              end

              it "renders the watchlist template" do
                get :watchlist, id: @user
                expect(response).to render_template(:watchlist)
              end

              it "returns a json object" do
                get :watchlist, id: @user, format: :json
                expect(response.headers['Content-Type']).to match 'application/json'
                expect(response.body).to eq(@user.watchlists.map(&:watched).to_json)
              end
            end
          end

        else
          it "does not assign a user" do
            user = create(:user)
            get :watchlist, params: {id: user}
            expect(assigns(:user)).to be_nil
          end

          it "renders access denied" do
            user = create(:user)
            get :watchlist, params: {id: user}
            expect(response).to render_template("pages/access_denied")
          end
        end
      end
    end

    shared_examples "can get a collection" do |accessible|
      describe 'GET #collection' do
        if accessible == true
          context 'with a public user' do
            let(:user) { create(:user, :with_multiple_collections)}

            before(:each) do
              user.update_attributes(:privacy => 2) #show collection
            end

            it "populates a user variable" do
              get :collection, params: {id: user}
              expect(assigns(:user)).to eq(user)
            end

            it "populates a records variable" do
              get :collection, params: {id: user}
              expect(assigns(:records)).to be_a Array
            end

            it "renders the collection template" do
              get :collection, params: {id: user}
              expect(response).to render_template(:collection)
            end

            it "returns a json object" do
              get :collection, params: {id: user}, format: :json
              expect(response.headers['Content-Type']).to match 'application/json'
              expect(response.body).to eq(user.collections.map(&:collected).to_json)
            end

            it "populates a type variable" do
              get :collection, params: {id: user}
              expect(assigns(:type)).to eq('collected')
            end

            it "matches the type variable if passed in" do
              get :collection, params: {id: user, type: "ignored"}
              expect(assigns(:type)).to eq("ignored")
            end

            it "responds to js" do
              get :collection, xhr: true, params: {id: user}, format: :js
              expect(response).to render_template(:collection)
            end
          end

          context 'with a shy user' do
            let(:user) { create(:user)}

            before(:each) do
              user.update_attributes(:privacy => 5) #show profile and show watchlist
            end

            it "populates a user record" do
              get :collection, params: {id: user}
              expect(assigns(:user)).to eq(user)
            end

            it "renders the private_page template" do
              get :collection, params: {id: user}
              expect(response).to render_template(:private_page)
            end

            it "returns forbidden with json" do
              get :collection, params: {id: user}, format: :json
              expect(response.status).to eq(403) #forbidden
            end

            it "responds to js" do
              get :collection, xhr: true, params: {id: user}, format: :js
              expect(response.status).to eq(403) #forbidden
            end
          end

          unless @user.nil?
            context "with the user's user" do
              it "populates a user variable" do
                get :collection, id: @user
                expect(assigns(:user)).to eq(@user)
              end

              it "renders the watchlist template" do
                get :collection, id: @user
                expect(response).to render_template(:collection)
              end

              it "returns a json object" do
                get :collection, id: @user, format: :json
                expect(response.headers['Content-Type']).to match 'application/json'
                expect(response.body).to eq(@user.collections.map(&:collected).to_json)
              end

              it "populates a type variable" do
                get :collection, id: @user
                expect(assigns(:type)).to eq("collected")
              end

              it "matches the type variable if passed in" do
                get :collection, id: @user, type: "ignored"
                expect(assigns(:type)).to eq("ignored")
              end

              it "responds to js" do
                get :collection, xhr: true, params: {id: @user}, format: :js
                expect(response).to render_template(:collection)
              end
            end
          end

        else
          it "does not assign a user" do
            user = create(:user)
            get :watchlist, params: {id: user}
            expect(assigns(:user)).to be_nil
          end

          it "renders access denied" do
            user = create(:user)
            get :watchlist, params: {id: user}
            expect(response).to render_template("pages/access_denied")
          end
        end

      end
    end

  #Edits/New
    shared_examples 'has a new user page' do |accessible, not_logged_in|
      describe 'GET #new' do

        if accessible == true
          if not_logged_in
            it 'renders new' do
              get :new
              valid_permissions(:new, accessible)
            end

            it 'assigns a new user' do
              get :new
              expect(assigns(:user)).to be_a_new(User)
            end

            it "renders new" do
              get :new
              expect(response).to render_template(:new)
            end

            it "renders json" do
              get :new, format: :json
              expect(response.headers['Content-Type']).to match 'application/json'
              expect(response.body).to eq(User.new.to_json)
            end

          else
            context "already signed in" do
              it "redirects to the front page" do
                get :new
                expect(response).to redirect_to(root_path)
              end

              it "renders 403 with json" do
                get :new, format: :json
                expect(response.status).to eq(403) #forbidden
              end
            end
          end

        else
          it "renders access denied as json" do
            get :new, format: :json
            expect(response.status).to eq(403) #forbidden
          end
        end

      end
    end

    shared_examples 'has an edit_security page' do |accessible|
      describe 'GET #edit_security' do
        let(:user) {create(:user)}

        it 'renders new' do
          get :edit_security, params: {id: user}
          valid_permissions(:edit_security, accessible)
        end

        if accessible == true
          it 'assigns a new user' do
            get :edit_security, params: {id: user}
            expect(assigns(:user)).to eq(user)
          end

          it "renders json" do
            get :edit_security, params: {id: user}, format: :json
            expect(response.headers['Content-Type']).to match 'application/json'
            expect(response.body).to eq(user.to_json)
          end
        else
          it "renders access denied as json" do
            get :edit_security, params: {id: user}, format: :json
            expect(response.status).to eq(403) #forbidden
          end
        end
      end
    end

    shared_examples 'has an edit_profile page' do |accessible|
      describe 'GET #edit_profile' do

        if accessible == true
          context "the user's edit_profile" do
            it 'assigns user' do
              get :edit_profile, params: {id: @user}
              expect(assigns(:user)).to eq(@user)
            end

            it "renders json" do
              get :edit_profile, params: {id: @user}, format: :json
              expect(response.headers['Content-Type']).to match 'application/json'
              expect(response.body).to eq(@user.to_json)
            end

            it "renders edit_profile" do
              get :edit_profile, params: {id: @user}
              expect(response).to render_template(:edit_profile)
            end
          end

          context "someone else's edit_profile" do
            it "renders access denied" do
              user = create(:user)
              get :edit_profile, params: {id: user}
              unless @user.abilities.include?("Admin")  #remove when admin abilities are implemented
                expect(response). to render_template("pages/access_denied")
              else
                expect(response).to render_template(:edit_profile)
              end
            end

            it "renders forbidden as json" do
              user = create(:user)
              get :edit_profile, params: {id: user}, format: :json
              unless @user.abilities.include?("Admin")  #remove when admin abilities are implemented
                expect(response.status).to eq(403) #forbidden
              else
                expect(response.body).to eq(user.to_json)
              end
            end
          end
        else
          it "renders access denied" do
            user = create(:user)
            get :edit_profile, params: {id: user}
            expect(response). to render_template("pages/access_denied")
          end

          it "renders access denied as json" do
            user = create(:user)
            get :edit_profile, params: {id: user}, format: :json
            expect(response.status).to eq(403) #forbidden
          end
        end
      end
    end

    shared_examples 'has an edit_watchlist page' do |accessible|
      describe 'GET #edit_watchlist' do

        if accessible == true
          context "the user's edit_watchlist" do
            it 'assigns user' do
              get :edit_watchlist, params: {id: @user}
              expect(assigns(:user)).to eq(@user)
            end

            it "renders json" do
              get :edit_watchlist, params: {id: @user}, format: :json
              expect(response.headers['Content-Type']).to match 'application/json'
              expect(response.body).to eq(@user.to_json)
            end

            it "renders edit_watchlist" do
              get :edit_watchlist, params: {id: @user}
              expect(response).to render_template(:edit_watchlist)
            end

          end

          context "someone else's edit_watchlist" do
            it "renders access denied" do
              user = create(:user)
              get :edit_watchlist, params: {id: user}
              unless @user.abilities.include?("Admin")  #remove when admin abilities are implemented
                expect(response). to render_template("pages/access_denied")
              else
                expect(response).to render_template(:edit_watchlist)
              end
            end

            it "renders forbidden as json" do
              user = create(:user)
              get :edit_watchlist, params: {id: user}, format: :json
              unless @user.abilities.include?("Admin")  #remove when admin abilities are implemented
                expect(response.status).to eq(403) #forbidden
              else
                expect(response.body).to eq(user.to_json)
              end
            end
          end
        else
          it "renders access denied" do
            user = create(:user)
            get :edit_watchlist, params: {id: user}
            expect(response). to render_template("pages/access_denied")
          end

          it "renders access denied as json" do
            user = create(:user)
            get :edit_watchlist, params: {id: user}, format: :json
            expect(response.status).to eq(403) #forbidden
          end
        end
      end
    end

  #Posts
    shared_examples "can post create user" do |accessible, not_logged_in|
      describe 'POST #create' do
        #For create, make sure it redirects to edit_profile
        if accessible == true
          if not_logged_in
            context 'with valid params' do
              it "makes a user" do
                expect{post :create, params: {user: attributes_for(:user)}}.to change(User, :count).by(1)
              end

              it 'calls the user defaulter service' do
                expect(UserDefaulter).to receive(:perform).and_return(User.new)
                post :create, params: {user: attributes_for(:user)}
              end

              it "assigns a user" do
                post :create, params: {user: attributes_for(:user)}
                expect(assigns(:user)).to be_a User
              end

              it "redirects to their edit_profile" do
                post :create, params: {user: attributes_for(:user)}
                expect(response).to redirect_to action: :edit_profile, id: User.last.id
              end

              it "has a notice" do
                post :create, params: {user: attributes_for(:user)}
                expect(flash[:notice]).to eq("Welcome to Hibiki! I highly recommend adjusting these settings to your preferences.")
              end

              it "renders the user as json" do
                post :create, params: {user: attributes_for(:user)}, format: :json
                expect(response.body).to eq(User.last.to_json)
              end
            end

            context 'without valid params' do
              it "does not create a user" do
                expect{post :create, params: {user: {:name => "bo"}}}.to change(User, :count).by(0)
              end

              it "should assign a user" do
                post :create, params: {user: {:name => "bo"}}
                expect(assigns(:user)).to be_a_new User
              end

              it "renders new" do
                post :create, params: {user: {:name => "bo"}}
                expect(response).to render_template :new
              end

              it "renders unprocessable entity with json" do
                post :create, params: {user: {:name => "bo"}}, format: :json
                expect(response.status).to eq(422) #aka Unprocessable entity /unprocess
              end
            end
          else
            context 'already logged in' do
              it "redirects to the front page" do
                post :create, params: {user: attributes_for(:user)}
                expect(response).to redirect_to(root_path)
              end

              it "renders 403 with json" do
                post :create, params: {user: attributes_for(:user)}, format: :json
                expect(response.status).to eq(403) #forbidden
              end

              it "does not make a user" do
                expect{post :create, params: {user: attributes_for(:user)}}.to change(User, :count).by(0)
              end

            end
          end
        else
          it "renders access denied" do
            post :create
            expect(response).to render_template("pages/access_denied")
          end

          it "renders 403 with json" do
            post :create, format: :json
            expect(response.status).to eq(403) #forbidden
          end

          it "does not make a user" do
            expect{post :create, params: {user: attributes_for(:user)}}.to change(User, :count).by(0)
          end
        end
      end
    end

    shared_examples "can post update_security" do |accessible|
      describe 'POST #update_security' do
        let(:user) {create(:user)}

        if accessible == true
          it "assigns the user" do
            post :update_security, params: {id: user, user: {role_ids: ["User", "Confident"]}}
            expect(assigns(:user)).to eq(user)
          end

          context 'with valid params' do
            it "calls the user security setter service" do
              expect(UserSecuritySetter).to receive(:perform).and_return(User.new)
              post :update_security, params: {id: user, user: {role_ids: ["User", "Confident"]}}
            end

            it "has a notice" do
              post :update_security, params: {user: {role_ids: ["User", "Confident"]}, id: user}
              expect(flash[:notice]).to eq "Security was successfully updated."
            end

            it "renders overview" do
              post :update_security, params: {id: user, user: {role_ids: ["User", "Confident"]}}
              expect(response).to redirect_to action: :overview, id: User.last.id
            end

            it "responds with success with json" do
              post :update_security, params: {id: user, user: {role_ids: ["User", "Confident"]}}, format: :json
              expect(response.status).to eq(204) #204 No Content no content -> ajax success event
            end


          end

          context 'with invalid params' do
            it 'renders edit_security' do
              post :update_security, params: {user: {status: "hoo"}, id: user}
              expect(response).to render_template(:edit_security)
            end

            it 'renders unprocessable_entity' do
              post :update_security, params: {user: {status: "hi"}, id: user}, format: :json
              expect(response.status).to eq(422) #aka Unprocessable entity /unprocess
            end
          end

        else
          it "renders access denied" do
            post :update_security, params: {id: user, user: {role_ids: ["User", "Confident"]}}
            expect(response).to render_template("pages/access_denied")
          end

          it "renders 403 with json" do
            post :update_security, params: {id: user, user: {role_ids: ["User", "Confident"]}}, format: :json
            expect(response.status).to eq(403) #forbidden
          end

        end
      end

    end

    shared_examples "can post update_profile" do |accessible|
      describe 'POST #update_profile' do
        let(:user) {create(:user)}

        if accessible == true
          it "assigns the user" do
            post :update_profile, params: {id: user, user: {display_form_settings: ["Display Limited Editions"]}}
            expect(assigns(:user)).to eq(user)
          end

          context "on oneself" do
            context 'with valid params' do
              it "calls update_attributes" do
                expect_any_instance_of(User).to receive(:update_attributes)
                post :update_profile, params: {id: @user, user: {display_form_settings: ["Display Limited Editions"]}}
              end

              it "updates some settings" do
                post :update_profile, params: {id: @user, user: {display_form_settings: ["Display Limited Editions"]}}
                expect(@user.reload.display_bitmask).to eq(1)
              end

              it "has a notice" do
                post :update_profile, params: {id: @user, user: {language_form_settings: ["english", "korean"]}}
                expect(flash[:notice]).to eq('Profile was successfully updated.')
              end

              it "renders edit_profile" do
                post :update_profile, params: {id: @user, user: {artist_language_form_settings: ["english", "korean"]}}
                expect(response).to redirect_to action: :edit_profile, id: User.last.id
              end

              it "renders success as json" do
                post :update_profile, params: {id: @user, user: {privacy_settings: ["Show Watchlist", "Show Profile"]}}, format: :json
                expect(response.status).to eq(204) #204 No Content no content -> ajax success event
              end
            end

            context 'with invalid params' do
              #There's no way there are invalid params?
              #There's no way to have @user.update_attributes return false in this method, I think.
              # it "renders edit_profile" do
                # post :update_profile, params: {id: @user, user: {ho: "Hah"}}
                # expect(response).to render_template(:edit_profile)
              # end
#
              # it "renders unprocessible entity as json" do
                # post :update_profile, params: {id: @user, user: {"haha" => "ha"}}, format: :json
                # expect(response.status).to eq(422) #aka Unprocessable entity /unprocess
              # end
            end
          end

          context "on another user" do
            it "renders access denied" do
              post :update_profile, params: {id: user, user: {display_settings: ["Show Limited Editions"]}}
              expect(response).to render_template("pages/access_denied")
            end

            it "renders 403 with json" do
              post :update_profile, params: {id: user, user: {display_settings: ["Show Limited Editions"]}}, format: :json
              expect(response.status).to eq(403) #forbidden
            end

            it "does not update any settings" do
              post :update_profile, params: {id: user, user: {display_settings: ["Show Limited Editions"]}}
              expect(user.reload.display_bitmask).to_not eq(1)
            end
          end

        else

          it "renders access denied" do
            post :update_profile, params: {id: user, user: {display_settings: ["Show Limited Editions"]}}
            expect(response).to render_template("pages/access_denied")
          end

          it "renders 403 with json" do
            post :update_profile, params: {id: user, user: {display_settings: ["Show Limited Editions"]}}, format: :json
            expect(response.status).to eq(403) #forbidden
          end

        end
      end
    end

    shared_examples "can post update_watchlist" do |accessible|
      describe 'POST #update_watchlist' do
        let(:user) {create(:user, :with_multiple_watchlists)}

        it "uses strong parameters" #This requires adding a method to users to update all of their watchlists.

        if accessible == true
          it "assigns the user" do
            post :update_watchlist, params: {id:user}
            expect(assigns(:user)).to eq(user)
          end

          context "on oneself" do
            context 'with valid params' do
              before(:each) do
                create_list(:watchlist, 3, user: @user)
              end

              it "updates a watchlist" do
                post :update_watchlist, params: {id:@user, watchlists: {"0" => {name: "haha", records: @user.watchlists.map(&:id)}}}
                expect(@user.reload.watchlists.first.grouping_category).to eq("haha")
              end

              it "has a notice" do
                post :update_watchlist, params: {id:@user, watchlists: {"0" => {name: "haha", records: @user.watchlists.map(&:id)}}}
                expect(flash[:notice]).to eq('Watchlist was successfully updated.')
              end

              it "renders edit_watchlist" do
                post :update_watchlist, params: {id:@user, watchlists: {"0" => {name: "haha", records: @user.watchlists.map(&:id)}}}
                expect(response).to redirect_to action: :edit_watchlist, id: User.last.id
              end

              it "renders success as json" do
                post :update_watchlist, params: {id:@user, watchlists: {"0" => {name: "haha", records: @user.watchlists.map(&:id)}}}, format: :json
                expect(response.status).to eq(204) #204 No Content no content -> ajax success event
              end
            end

            context 'with invalid params' do
              #Invalid parameter: grouping category is > 43 characters

              it "renders edit_profile" do
                post :update_watchlist, params: {id:@user}
                expect(response).to render_template(:edit_watchlist)
              end

              it "renders unprocessible entity as json" do
                post :update_watchlist, params: {id:@user}, format: :json
                expect(response.status).to eq(422) #aka Unprocessable entity /unprocess
              end
            end
          end

          context "on another user" do
            it "renders access denied" do
              post :update_watchlist, params: {id:user, watchlists: {"0" => {name: "haha", records: user.watchlists.map(&:id)}}}
              expect(response).to render_template("pages/access_denied")
            end

            it "renders 403 with json" do
              post :update_watchlist, params: {id:user, watchlists: {"0" => {name: "haha", records: user.watchlists.map(&:id)}}}, format: :json
              expect(response.status).to eq(403) #forbidden
            end

            it "does not call save on watchlists" do
              expect_any_instance_of(Watchlist).to_not receive(:save)
              post :update_watchlist, params: {id:user, watchlists: {"0" => {name: "haha", records: user.watchlists.map(&:id)}}}
            end

            it "does not update any watchlists" do
              post :update_watchlist, params: {id:user, watchlists: {"0" => {name: "haha", records: user.watchlists.map(&:id)}}}
              expect(user.reload.watchlists.first.grouping_category).to_not eq("haha")
            end
          end
        else
          it "renders access denied" do
            post :update_watchlist, params: {id:user, watchlists: {"0" => {name: "haha", records: user.watchlists.map(&:id)}}}
            expect(response).to render_template("pages/access_denied")
          end

          it "renders 403 with json" do
            post :update_watchlist, params: {id:user, watchlists: {"0" => {name: "haha", records: user.watchlists.map(&:id)}}}, format: :json
            expect(response.status).to eq(403) #forbidden
          end

          it "does not call save on watchlists" do
            expect_any_instance_of(Watchlist).to_not receive(:save)
            post :update_watchlist, params: {id:user, watchlists: {"0" => {name: "haha", records: user.watchlists.map(&:id)}}}
          end
        end
      end
    end

  shared_examples "can get a new grouping" do |accessible|
    describe 'GET #add_grouping' do
      if accessible == true
        it "renders js" do
          get :add_grouping, xhr: true, format: :js
          expect(response).to render_template(:add_grouping)
        end
      else
        it "renders access denied" do
          get :add_grouping
          expect(response).to render_template("pages/access_denied")
        end

        it "renders forbidden with js" do
          get :add_grouping, xhr: true, format: :js
          expect(response.status).to eq(403) #forbidden
        end
      end
    end
  end

  #Authenticate
  before :each do
    activate_authlogic
  end

  context 'public access to users' do
    #JS
    include_examples "can collect/uncollect", false
    include_examples "can watch/unwatch", false

    #Index/Show
    include_examples "has an index page", false, :id
    include_examples "has a user show page", true #General page
    include_examples "has an overview page", false #Admin-details page
    include_examples "can get a watchlist", true
    include_examples "can get a collection", true

    #Edits/New
    include_examples "has a new user page", true, true
    include_examples "has an edit_security page", false
    include_examples "has an edit_profile page", false
    include_examples "has an edit_watchlist page", false
    include_examples "can get a new grouping", false

    #Posts
    include_examples "can post create user", true, true
    include_examples "can post update_security", false
    include_examples "can post update_profile", false
    include_examples "can post update_watchlist", false

    #Delete
    include_examples "can delete a record", false

    #Strong Parameters
    include_examples "uses strong parameters", valid_params: ["password", "name", "password_confirmation", "email"]

  end

  context 'user access to users' do
    before :each do
      @user = create(:user, :user_role)
      UserSession.create(@user)
    end

    #JS
    include_examples "can collect/uncollect", true
    include_examples "can watch/unwatch", true

    #Index/Show
    include_examples "has an index page", false, :id
    include_examples "has a user show page", true #General page
    include_examples "has an overview page", false #Admin-details page
    include_examples "can get a watchlist", true
    include_examples "can get a collection", true

    #Edits/New
    include_examples "has a new user page", true, false
    include_examples "has an edit_security page", false
    include_examples "has an edit_profile page", true
    include_examples "has an edit_watchlist page", true
    include_examples "can get a new grouping", true

    #Posts
    include_examples "can post create user", true, false
    include_examples "can post update_security", false
    include_examples "can post update_profile", true
    include_examples "can post update_watchlist", true

    #Delete
    include_examples "can delete a record", false

    #Strong Parameters
    include_examples "uses strong parameters", invalid_params: ["password", "name", "password_confirmation", "email"]
    include_examples "uses strong parameters", valid_params: [["language_form_settings"], ["artist_language_form_settings"],
                                                ["display_form_settings"],["privacy_form_settings"]], filter_method: "profile_filter"

  end

  context 'admin access to users' do
    before :each do
      @user = create(:user, :admin_role)
      UserSession.create(@user)
    end

    #JS
    include_examples "can collect/uncollect", true
    include_examples "can watch/unwatch", true

    #Index/Show
    include_examples "has an index page", true, :id
    include_examples "has a user show page", true #General page
    include_examples "has an overview page", true #Admin-details page
    include_examples "can get a watchlist", true
    include_examples "can get a collection", true

    #Edits/New
    include_examples "has a new user page", true, false
    include_examples "has an edit_security page", true
    include_examples "has an edit_profile page", true
    include_examples "has an edit_watchlist page", true
    include_examples "can get a new grouping", true

    #Posts
    include_examples "can post create user", true, false
    include_examples "can post update_security", true
    include_examples "can post update_profile", true
    include_examples "can post update_watchlist", true

    #Delete
    include_examples "can delete a record", true

    #Strong Parameters
    include_examples "uses strong parameters", invalid_params: ["password", "name", "password_confirmation", "email"]
    include_examples "uses strong parameters", valid_params: ["status", ["role_ids"]], filter_method: "security_filter"
    include_examples "uses strong parameters", valid_params: [["language_form_settings"], ["artist_language_form_settings"],
                                                              ["display_form_settings"],["privacy_form_settings"]],filter_method: "profile_filter"

  end
end


