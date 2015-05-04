require 'rails_helper'

describe ScriptsController do
  shared_examples "it quietly fails" do |method|
      it "quietly fails without the right inputs" do
        #quietly failing = error finding the div, etc.
        #The controller will just pass through to the js and 
        #no checks will be made or errors thrown
        xhr :get, method, format: :js
        expect(response).to render_template(method)
      end
  end
  
  shared_examples "get toggle_albums" do |accessible|
    describe '#GET toggle_albums' do      
      if accessible == true
        it "responds to js" do
          xhr :get, :toggle_albums, format: :js
          expect(response).to render_template(:toggle_albums)
        end     
          
        context "aos params" do
          it "handles all_albums params" do
            expect(Album).to receive(:where).with(nil)
            xhr :get, :toggle_albums,  :all_albums => "true", format: :js
          end
        
          it "prioritizes all_albums over aos" do
            expect(Album).to receive(:where).with(nil)
            xhr :get, :toggle_albums,  :all_albums => "true", aos: "s21", format: :js
          end
        
          it "handles aos params" do
            expect(Album).to receive(:with_artist_organization_source)
            xhr :get, :toggle_albums,  :aos => "s232", format: :js
          end
          
          it "returns nothing if aos params are malformed" do
            expect(Album).to receive(:none)
            xhr :get, :toggle_albums,  :aos => "xhd", format: :js
          end
        end
        
        context "release_type params" do
          it "handles release type params" do
            expect(Album).to receive(:with_self_relation_categories)
            xhr :get, :toggle_albums,  :rel => "1,2", format: :js
          end
          
          it "handles an N category" do
            expect(Album).to receive(:filters_by_self_relation_categories)
            xhr :get, :toggle_albums,  :rel => "N,1,2", format: :js
          end
          
          it "ignores release_type" do
            expect(Album).to_not receive(:with_self_relation_categories)
            expect(Album).to_not receive(:filters_by_self_relation_categories)
            xhr :get, :toggle_albums, :all_albums => "true", format: :js
          end
        end
        
        context "date params" do
          it "handles date params" do
            expect(Album).to receive(:in_date_range)
            xhr :get, :toggle_albums, :date1 => "321", :date2 => "312", format: :js            
          end
          
          it "ignores a nil date_params" do
            expect(Album).to_not receive(:in_date_range)
            xhr :get, :toggle_albums, :all_albums => "true", format: :js
          end
        end
        
        context "collection params" do
          it "handles collection params" do
            expect(Album).to receive(:in_collection)
            xhr :get, :toggle_albums,  :col => "2", format: :js
          end
          
          it "handles N in collection params" do
            expect(Album).to receive(:collection_filter)
            xhr :get, :toggle_albums, :col => "N,1,2", format: :js
          end
          
          it "handles no collection params" do
            expect(Album).to_not receive(:collection_filter)
            expect(Album).to_not receive(:in_collection)
            xhr :get, :toggle_albums, :all_albums => "true", format: :js
          end
        end
        
        context "tag params" do
          it "handles tag params" do
            expect(Album).to receive(:with_tag)
            xhr :get, :toggle_albums, :tag => "2,4,52", format: :js
          end
          
          it "handles no tag params" do
            expect(Album).to_not receive(:with_tag)
            xhr :get, :toggle_albums, :all_albums => "true", format: :js
          end
        end
          
        context "sort params" do
          it "handles sort params" do
            xhr :get, :toggle_albums, :all_albums => "true", :sort => "wala", format: :js
            expect(assigns(:sort)).to eq("year")            
          end
          
          it "rejects fake sort params" do
            xhr :get, :toggle_albums, :all_albums => "true", :sort => "Week", format: :js
            expect(assigns(:sort)).to eq("week")
          end
          
          it "handles no sort params" do
            xhr :get, :toggle_albums, :all_albums => "true", format: :js
            expect(assigns(:sort)).to eq("year")
          end     
        end
        
        it "handles no params and returns nothing" do
          create(:album)
          xhr :get, :toggle_albums, format: :js
          expect(assigns(:albums)).to be_empty          
        end
        
        include_examples "it quietly fails", :toggle_albums
        
        it "responds to json" do
          album_list = create_list(:album, 2)
          get :toggle_albums, :all_albums => "true", format: :json
          expect(response.body).to eq(album_list.to_json)
        end
      else
        it "renders access denied" do
          xhr :get, :toggle_albums, format: :js
          expect(response.status).to eq(403) #forbidden
        end        
      end
    end    
  end  
  
  shared_examples 'get add_reference_form' do |accessible|
    describe '#GET add_reference_form' do
      
      if accessible == true
        it "responds to js" do
          xhr :get, :add_reference_form, format: :js
          expect(response).to render_template(:add_reference_form)
        end
        
        it "assigns div_id" do
          xhr :get, :add_reference_form, format: :js, div_id: "wooo"
          expect(assigns(:div_id)).to eq("wooo")
        end
        
        it "assigns fields_for" do
          xhr :get, :add_reference_form, format: :js, fields_for: "weee"
          expect(assigns(:fields_for)).to eq("weee")
        end
        
        include_examples "it quietly fails", :add_reference_form
      else
        it "renders access denied" do
          xhr :get, :add_reference_form, format: :js
          expect(response.status).to eq(403) #forbidden
        end        
      end
    end    
  end

  shared_examples 'get add_model_form' do |accessible|
    describe '#GET add_model_form' do
      if accessible == true
        it "responds to js" do
          xhr :get, :add_model_form, format: :js, parent_div: "hoho!"
          expect(response).to render_template(:add_model_form)
        end
        
        it "assigns a parent div" do
          xhr :get, :add_model_form, format: :js, parent_div: "hoho!"
          expect(assigns(:parent_div)).to eq("hoho!")
        end
        
        include_examples "it quietly fails", :add_model_form
      else
        it "renders access denied" do
          xhr :get, :add_model_form, format: :js
          expect(response.status).to eq(403) #forbidden
        end        
      end
      
    end      
  end

  shared_examples 'get well_toggle' do |accessible|
    describe '#GET well_toggle' do
      if accessible == true
        it "responds to js" do
          xhr :get, :well_toggle, format: :js, div_id: 'hi!', toggle_id: "yo!"
          expect(response).to render_template(:well_toggle)
        end
        
        it "assigns div_id" do
          xhr :get, :well_toggle, format: :js, div_id: 'hi!', toggle_id: "yo!"
          expect(assigns(:div_id)).to eq("hi!")
        end
        
        it "assigns toggle_id" do
          xhr :get, :well_toggle, format: :js, div_id: 'hi!', toggle_id: "yo!"
          expect(assigns(:toggle_id)).to eq("yo!")
        end
        
        include_examples "it quietly fails", :well_toggle
      else
        it "renders access denied" do
          xhr :get, :well_toggle, format: :js
          expect(response.status).to eq(403) #forbidden
        end
      end
    end    
  end

  shared_examples 'post add_tag' do |accessible|
    describe '#POST add_tag' do
      
      if accessible == true
        context "with valid attributes" do
          let(:tag) {create(:tag)}
          let(:record) {create(:album)}
          
          it "creates a taglist" do
            expect{post :add_tag, tag_id: tag.id, subject_id: record.id, subject_type: record.class.to_s}.to change(Taglist,:count).by(1)
          end
          
          it "assigns record_id" do
            post :add_tag, tag_id: tag.id, subject_id: record.id, subject_type: record.class.to_s
            expect(assigns(:record_id)).to eq(record.id.to_s)
          end
          
          it "assigns tag_id" do
            post :add_tag, tag_id: tag.id, subject_id: record.id, subject_type: record.class.to_s
            expect(assigns(:tag_id)).to eq(tag.id.to_s)
          end
          
          it "responds to js" do
            xhr :post, :add_tag, tag_id: tag.id, subject_id: record.id, subject_type: record.class.to_s, format: :js
            expect(response).to render_template(:add_tag)
            expect(assigns(:msg)).to start_with("Added")
          end
          
          it "responds to html" do
            post :add_tag, tag_id: tag.id, subject_id: record.id, subject_type: record.class.to_s
            expect(response).to redirect_to(record)
            expect(flash[:notice]).to start_with("Successfully")
          end
        end
        
        context "with invalid attributes" do
          let(:tag) {create(:tag)}
          let(:record) {create(:album)}
          
          it "does not add a taglist if there's already one" do
            create(:taglist, tag: tag, subject: record)
            expect{post :add_tag, tag_id: tag.id, subject_id: record.id, subject_type: record.class.to_s}.to change(Taglist,:count).by(0)
          end
          
          it "does not add a taglist without a real album" do
            expect{post :add_tag, tag_id: tag.id, subject_id: 3432432, subject_type: record.class.to_s}.to change(Taglist,:count).by(0)
          end
          
          it "does not add a taglist without a tag" do
            expect{post :add_tag, tag_id: 4214123, subject_id: record.id, subject_type: record.class.to_s}.to change(Taglist,:count).by(0)
          end
          
          it "responds to js" do
            xhr :post, :add_tag, tag_id: "24232", subject_id: record.id, subject_type: record.class.to_s, format: :js
            expect(assigns(:msg)).to start_with("Failed")
          end
          
          it "responds to html" do
            post :add_tag, tag_id: 4214123, subject_id: record.id, subject_type: record.class.to_s
            expect(flash[:notice]).to start_with("FAILED:")      
          end
        end
      else
        it "renders access denied" do
          post :add_tag
          expect(response).to render_template("pages/access_denied")
        end
        
        it "renders access denied if js is sent in" do
          xhr :post, :add_tag, format: :js
          expect(response.status).to eq(403) #forbidden
        end
      end      
      
    end
  end
  
  shared_examples 'post remove_tag' do |accessible|
    describe '#POST remove_tag' do
      if accessible == true
        context 'with valid params' do
          let(:tag) {create(:tag)}
          let(:record) {create(:album)}
          before(:each) do
            create(:taglist, tag: tag, subject: record)
          end
          
          it "destroys a taglist" do
            expect {post :remove_tag, tag_id: tag.id, subject_id: record.id, subject_type: record.class.to_s}.to change(Taglist,:count).by(-1)
          end
          
          it "assigns tag_id" do
            post :remove_tag, tag_id: tag.id, subject_id: record.id, subject_type: record.class.to_s
            expect(assigns(:tag_id)).to eq(tag.id.to_s)
          end
          
          it "assigns record_id" do
            post :remove_tag, tag_id: tag.id, subject_id: record.id, subject_type: record.class.to_s
            expect(assigns(:record_id)).to eq(record.id.to_s)
          end
          
          it "responds to js" do
            xhr :post, :remove_tag, tag_id: tag.id, subject_id: record.id, subject_type: record.class.to_s, format: :js
            expect(response).to render_template(:remove_tag)
            expect(assigns(:msg)).to start_with("Removed")
          end
          
          it "responds to html" do
            post :remove_tag, tag_id: tag.id, subject_id: record.id, subject_type: record.class.to_s
            expect(response).to redirect_to(record)
            expect(flash[:notice]).to start_with("Successfully")            
          end          
        end
        
        context 'with invalid params' do
          let(:tag) {create(:tag)}
          let(:record) {create(:album)}
          before(:each) do
            create(:taglist, tag: tag, subject: record)
          end

          it "does not add a taglist without a tag" do
            expect{post :remove_tag, tag_id: 4214123, subject_id: record.id, subject_type: record.class.to_s}.to change(Taglist,:count).by(0)
          end
          
          it "responds to js" do
            xhr :post, :remove_tag, tag_id: "24232", subject_id: record.id, subject_type: record.class.to_s, format: :js
            expect(assigns(:msg)).to start_with("Failed")
          end
          
          it "responds to html" do
            post :remove_tag, tag_id: 4214123, subject_id: record.id, subject_type: record.class.to_s
            expect(flash[:notice]).to start_with("Failed")      
          end
                    
        end
      else
        it "renders access denied" do
          post :remove_tag
          expect(response).to render_template("pages/access_denied")
        end
        
        it "renders access denied if js is sent in" do
          xhr :post, :remove_tag, format: :js
          expect(response.status).to eq(403) #forbidden
        end      
      end
    end
  end
  

  #Authenticate
  before :each do
    activate_authlogic
  end
  
  context 'public access to artists' do
    before :each do
      @user = create(:user, security: "0")
      UserSession.create(@user)
    end
    
    #JS 
    include_examples 'get toggle_albums', true
    
    #JS for Edit Forms
    include_examples 'get add_reference_form', false
    include_examples 'get add_model_form', false
    include_examples 'get well_toggle', false
    
    include_examples 'post add_tag', false
    include_examples 'post remove_tag', false
    
      
  end
  
  context 'user access to artists' do
    before :each do
      @user = create(:user)
      UserSession.create(@user)
    end
    
    #JS 
    include_examples 'get toggle_albums', true
    
    #JS for Edit Forms
    include_examples 'get add_reference_form', false
    include_examples 'get add_model_form', false
    include_examples 'get well_toggle', false
    
    include_examples 'post add_tag', false
    include_examples 'post remove_tag', false
    
  end

  context 'admin access to artists' do
    before :each do
      @user = create(:admin)
      UserSession.create(@user)
    end
    
    #JS 
    include_examples 'get toggle_albums', true
    
    #JS for Edit Forms
    include_examples 'get add_reference_form', true
    include_examples 'get add_model_form', true
    include_examples 'get well_toggle', true
    
    include_examples 'post add_tag', true
    include_examples 'post remove_tag', true
  end
   
end


