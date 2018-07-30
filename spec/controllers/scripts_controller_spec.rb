require 'rails_helper'

describe ScriptsController do
  shared_examples "it quietly fails" do |method|
    it "quietly fails without the right inputs" do
      #quietly failing = error finding the div, etc.
      #The controller will just pass through to the js and 
      #no checks will be made or errors thrown
      get method, xhr: true, format: :js
      expect(response).to render_template(method)
    end
  end
  
  shared_examples "get toggle_albums" do |accessible|
    describe '#GET toggle_albums' do      
      if accessible == true
        it "responds to js" do
          get :toggle_albums, xhr: true, format: :js
          expect(response).to render_template(:toggle_albums)
        end     
          
        context "aos params" do
          it "handles all_albums params" do
            expect(Album).to receive(:where).with(nil)
            get :toggle_albums, xhr: true, params: {:all_albums => "true"}, format: :js
          end
        
          it "prioritizes all_albums over aos" do
            expect(Album).to receive(:where).with(nil)
            get :toggle_albums, xhr: true, params: {:all_albums => "true", aos: "s21"}, format: :js
          end
        
          it "handles aos params" do
            expect(Album).to receive(:with_artist_organization_source)
            get :toggle_albums, xhr: true, params: {:aos => "s232"}, format: :js
          end
          
          it "returns nothing if aos params are malformed" do
            expect(Album).to receive(:none)
            get :toggle_albums, xhr: true, params: {:aos => "xhd"}, format: :js
          end
        end
        
        context "release_type params" do
          it "handles release type params" do
            expect(Album).to receive(:with_self_relation_categories)
            get :toggle_albums, xhr: true, params: {:rel => "1,2"}, format: :js
          end
          
          it "handles an N category" do
            expect(Album).to receive(:without_self_relation_categories)
            get :toggle_albums, xhr: true, params: {:rel => "N,1,2"}, format: :js
          end
          
          it "ignores release_type" do
            expect(Album).to_not receive(:with_self_relation_categories)
            expect(Album).to_not receive(:without_self_relation_categories)
            get :toggle_albums, xhr: true, params: {:all_albums => "true"}, format: :js
          end
        end
        
        context "date params" do
          it "handles date params" do
            expect(Album).to receive(:in_date_range)
            get :toggle_albums, xhr: true, params: {:date1 => "321", :date2 => "312"}, format: :js
          end
          
          it "ignores a nil date_params" do
            expect(Album).to_not receive(:in_date_range)
            get :toggle_albums, xhr: true, params: {:all_albums => "true"}, format: :js
          end
        end
        
        context "collection params" do
          it "handles collection params" do
            unless @user.nil?
              expect(Album).to receive(:in_collection)
            else
              expect(Album).to_not receive(:in_collection)
            end
            get :toggle_albums, xhr: true, params: {:col => "2"}, format: :js
          end
          
          it "handles N in collection params" do
            unless @user.nil?
              expect(Album).to receive(:not_in_collection)
            else
              expect(Album).to_not receive(:not_in_collection)
            end
            get :toggle_albums, xhr: true, params: {:col => "N,1,2"}, format: :js
          end
          
          it "handles no collection params" do
            expect(Album).to_not receive(:not_in_collection)
            expect(Album).to_not receive(:in_collection)
            get :toggle_albums, xhr: true, params: {:all_albums => "true"}, format: :js
          end
        end
        
        context "tag params" do
          it "handles tag params" do
            expect(Album).to receive(:with_tag)
            get :toggle_albums, xhr: true, params: {:tag => "2,4,52"}, format: :js
          end
          
          it "handles no tag params" do
            expect(Album).to_not receive(:with_tag)
            get :toggle_albums, xhr: true, params: {:all_albums => "true"}, format: :js
          end
        end
          
        context "sort params" do
          it "handles sort params" do
            get :toggle_albums, xhr: true, params: {:all_albums => "true", :sort => "wala"}, format: :js
            expect(assigns(:sort)).to eq("year")            
          end
          
          it "rejects fake sort params" do
            get :toggle_albums, xhr: true, params: {:all_albums => "true", :sort => "Week"}, format: :js
            expect(assigns(:sort)).to eq("week")
          end
          
          it "handles no sort params" do
            get :toggle_albums, xhr: true, params: {:all_albums => "true"}, format: :js
            expect(assigns(:sort)).to eq("year")
          end     
        end
        
        it "handles no params and returns nothing" do
          create(:album)
          get :toggle_albums, xhr: true,  format: :js
          expect(assigns(:albums)).to be_empty          
        end
        
        include_examples "it quietly fails", :toggle_albums
        
        it "responds to json" do
          album_list = create_list(:album, 2)
          get :toggle_albums, params: {:all_albums => "true"}, format: :json
          expect(response.body).to eq(album_list.to_json)
        end
      else
        it "renders access denied" do
          get :toggle_albums, xhr: true,  format: :js
          expect(response.status).to eq(403) #forbidden
        end        
      end
    end    
  end  
  
  shared_examples 'get autocomplete' do |accessible|
    describe '#GET autocomplete' do
      if accessible == true
        it "returns some json" do
          get :autocomplete, xhr: true,  format: :js, params: {term: "hi"}
          expect(response.status).to eq(200)
        end
        
        it 'populates @json_results' do
          get :autocomplete, xhr: true,  format: :js, params: {term: "hi"}
          expect(assigns(:json_results)).to_not be_nil
        end
      else
        it "renders access denied" do
          get :autocomplete, xhr: true,  format: :js
          expect(response.status).to eq(403) #forbidden
        end        
      end
    end
  end
  
  shared_examples 'get add_model_form' do |accessible|
    describe '#GET add_model_form' do
      if accessible == true
        it "responds to js" do
          get :add_model_form, xhr: true, format: :js, params: {parent_div: "hoho!"}
          expect(response).to render_template(:add_model_form)
        end
        
        it "assigns a parent div" do
          get :add_model_form, xhr: true, format: :js, params: {parent_div: "hoho!"}
          expect(assigns(:parent_div)).to eq("hoho!")
        end
        
        include_examples "it quietly fails", :add_model_form
      else
        it "renders access denied" do
          get :add_model_form, xhr: true, format: :js
          expect(response.status).to eq(403) #forbidden
        end        
      end
      
    end      
  end

  shared_examples 'get well_toggle' do |accessible|
    describe '#GET well_toggle' do
      if accessible == true
        it "responds to js" do
          get :well_toggle, xhr: true, format: :js, params: {div_id: 'hi!', toggle_id: "yo!"}
          expect(response).to render_template(:well_toggle)
        end
        
        it "assigns div_id" do
          get :well_toggle, xhr: true, format: :js, params: {div_id: 'hi!', toggle_id: "yo!"}
          expect(assigns(:div_id)).to eq("hi!")
        end
        
        it "assigns toggle_id" do
          get :well_toggle, xhr: true, format: :js, params: {div_id: 'hi!', toggle_id: "yo!"}
          expect(assigns(:toggle_id)).to eq("yo!")
        end
        
        include_examples "it quietly fails", :well_toggle
      else
        it "renders access denied" do
          get :well_toggle, xhr: true, format: :js
          expect(response.status).to eq(403) #forbidden
        end
      end
    end    
  end

  shared_examples 'post add_tag' do |accessible|
    describe '#POST add_tag' do
      
      if accessible == true
        context "with valid attributes" do
          let(:tag) {create(:tag, model_bitmask: 1)}
          let(:record) {create(:album)}
          
          it "creates a taglist" do
            expect{post :add_tag, params: {tag_id: tag.id, subject_id: record.id, subject_type: record.class.to_s}}.to change(Taglist,:count).by(1)
          end
          
          it "assigns record_id" do
            post :add_tag, params: {tag_id: tag.id, subject_id: record.id, subject_type: record.class.to_s}
            expect(assigns(:record_id)).to eq(record.id.to_s)
          end
          
          it "assigns tag_id" do
            post :add_tag, params: {tag_id: tag.id, subject_id: record.id, subject_type: record.class.to_s}
            expect(assigns(:tag_id)).to eq(tag.id.to_s)
          end
          
          it "responds to js" do
            post :add_tag, xhr: true, params: {tag_id: tag.id, subject_id: record.id, subject_type: record.class.to_s}, format: :js
            expect(response).to render_template(:add_tag)
            expect(assigns(:msg)).to start_with("Added")
          end
          
          it "responds to html" do
            post :add_tag, params: {tag_id: tag.id, subject_id: record.id, subject_type: record.class.to_s}
            expect(response).to redirect_to(record)
            expect(flash[:notice]).to start_with("Successfully")
          end
        end
        
        context "with invalid attributes" do
          let(:tag) {create(:tag, model_bitmask: 1)}
          let(:record) {create(:album)}
          
          it "does not add a taglist if there's already one" do
            create(:taglist, tag: tag, subject: record)
            expect{post :add_tag, params: {tag_id: tag.id, subject_id: record.id, subject_type: record.class.to_s}}.to change(Taglist,:count).by(0)
          end
          
          it "does not add a taglist without a real album" do
            expect{post :add_tag, params: {tag_id: tag.id, subject_id: 3432432, subject_type: record.class.to_s}}.to change(Taglist,:count).by(0)
          end
          
          it "does not add a taglist without a tag" do
            expect{post :add_tag, params: {tag_id: 4214123, subject_id: record.id, subject_type: record.class.to_s}}.to change(Taglist,:count).by(0)
          end
          
          it "responds to js" do
            post :add_tag, xhr: true, params: {tag_id: "24232", subject_id: record.id, subject_type: record.class.to_s}, format: :js
            expect(assigns(:msg)).to start_with("Failed")
          end
          
          it "responds to html" do
            post :add_tag, params: {tag_id: 4214123, subject_id: record.id, subject_type: record.class.to_s}
            expect(flash[:notice]).to start_with("FAILED:")      
          end
        end
      else
        it "renders access denied" do
          post :add_tag
          expect(response).to render_template("pages/access_denied")
        end
        
        it "renders access denied if js is sent in" do
          post :add_tag, xhr: true, format: :js
          expect(response.status).to eq(403) #forbidden
        end
      end      
      
    end
  end
  
  shared_examples 'post remove_tag' do |accessible|
    describe '#POST remove_tag' do
      if accessible == true
        context 'with valid params' do
          let(:tag) {create(:tag, model_bitmask: 1)}
          let(:record) {create(:album)}
          before(:each) do
            create(:taglist, tag: tag, subject: record)
          end
          
          it "destroys a taglist" do
            expect {post :remove_tag, params: {tag_id: tag.id, subject_id: record.id, subject_type: record.class.to_s}}.to change(Taglist,:count).by(-1)
          end
          
          it "assigns tag_id" do
            post :remove_tag, params: {tag_id: tag.id, subject_id: record.id, subject_type: record.class.to_s}
            expect(assigns(:tag_id)).to eq(tag.id.to_s)
          end
          
          it "assigns record_id" do
            post :remove_tag, params: {tag_id: tag.id, subject_id: record.id, subject_type: record.class.to_s}
            expect(assigns(:record_id)).to eq(record.id.to_s)
          end
          
          it "responds to js" do
            post :remove_tag, xhr: true, params: {tag_id: tag.id, subject_id: record.id, subject_type: record.class.to_s}, format: :js
            expect(response).to render_template(:remove_tag)
            expect(assigns(:msg)).to start_with("Removed")
          end
          
          it "responds to html" do
            post :remove_tag, params: {tag_id: tag.id, subject_id: record.id, subject_type: record.class.to_s}
            expect(response).to redirect_to(record)
            expect(flash[:notice]).to start_with("Successfully")            
          end          
        end
        
        context 'with invalid params' do
          let(:tag) {create(:tag, model_bitmask: 1)}
          let(:record) {create(:album)}
          before(:each) do
            create(:taglist, tag: tag, subject: record)
          end

          it "does not add a taglist without a tag" do
            expect{post :remove_tag, params: {tag_id: 4214123, subject_id: record.id, subject_type: record.class.to_s}}.to change(Taglist,:count).by(0)
          end
          
          it "responds to js" do
            post :remove_tag, xhr: true, params: {tag_id: "24232", subject_id: record.id, subject_type: record.class.to_s}, format: :js
            expect(assigns(:msg)).to start_with("Failed")
          end
          
          it "responds to html" do
            post :remove_tag, params: {tag_id: 4214123, subject_id: record.id, subject_type: record.class.to_s}
            expect(flash[:notice]).to start_with("Failed")      
          end
                    
        end
      else
        it "renders access denied" do
          post :remove_tag
          expect(response).to render_template("pages/access_denied")
        end
        
        it "renders access denied if js is sent in" do
          post :remove_tag, xhr: true, format: :js
          expect(response.status).to eq(403) #forbidden
        end      
      end
    end
  end
  

  #Authenticate
  before :each do
    activate_authlogic
  end
  
  context 'public access to scripts' do
    
    #JS 
    include_examples 'get toggle_albums', true
    include_examples 'get autocomplete', true
    
    #JS for Edit Forms
    include_examples 'get add_model_form', false
    include_examples 'get well_toggle', false
    
    include_examples 'post add_tag', false
    include_examples 'post remove_tag', false

  end
  
  context 'user access to scripts' do
    before :each do
      @user = create(:user)
      UserSession.create(@user)
    end
    
    #JS 
    include_examples 'get toggle_albums', true
    include_examples 'get autocomplete', true
    
    #JS for Edit Forms
    include_examples 'get add_model_form', false
    include_examples 'get well_toggle', false
    
    include_examples 'post add_tag', false
    include_examples 'post remove_tag', false
    
  end

  context 'admin access to scripts' do
    before :each do
      @user = create(:admin)
      UserSession.create(@user)
    end
    
    #JS 
    include_examples 'get toggle_albums', true
    include_examples 'get autocomplete', true
    
    #JS for Edit Forms
    include_examples 'get add_model_form', true
    include_examples 'get well_toggle', true
    
    include_examples 'post add_tag', true
    include_examples 'post remove_tag', true
  end
   
end


