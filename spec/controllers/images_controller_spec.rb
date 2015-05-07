require 'rails_helper'

describe ImagesController do

  shared_examples "has an update_image js" do |accessible|
    describe "GET #update_image" do
      if accessible == true
        it "responds to js" do
          image = create(:image)
          xhr :get, :update_image, id: image.id, format: :js
          expect(response).to render_template :update_image
        end
        
        it "populates @image" do
          image = create(:image)
          xhr :get, :update_image, id: image.id, format: :js
          expect(assigns(:image)).to eq(image)
        end
        
        it "does not populate @show_nws if not passed in" do
          image = create(:image)
          xhr :get, :update_image, id: image.id, format: :js
          expect(assigns(:show_nws)).to eq(nil)
        end
        
        it "populates @show_nws if passed in" do
          image = create(:image)
          xhr :get, :update_image, id: image.id, format: :js, show_nws: true
          expect(assigns(:show_nws)).to eq(true)
        end
      else
        it "renders access denied" do
          xhr :get, :update_image, id: image.id, format: :js
          expect(response).to render_template("pages/access_denied")
        end
      end
    end
  end  
  
  #Authenticate
  before :each do
    activate_authlogic
  end
  
  context 'public access to images' do    
    #Ajax
      include_examples "has an update_image js", true
    
    #Shows
      include_examples 'has an index page', false, :id
      include_examples "has a show page", false
      
    #Edits
      include_examples "has an edit page", false

    #Posts
      include_examples "can post update", false, :name

    #Delete
      include_examples "can delete a record", false
      
  end
  
  context 'user access to images' do
    before :each do
      @user = create(:user)
      UserSession.create(@user)
    end
    
    #Ajax
      include_examples "has an update_image js", true
    
    #Shows
      include_examples 'has an index page', false, :id
      include_examples "has a show page", false
      
    #Edits
      include_examples "has an edit page", false

    #Posts
      include_examples "can post update", false, :name

    #Delete
      include_examples "can delete a record", false

  end

  context 'admin access to images' do
    before :each do
      @user = create(:admin)
      UserSession.create(@user)
    end
    
    #Ajax
      include_examples "has an update_image js", true
    
    #Shows
      include_examples 'has an index page', true, :id
      include_examples "has a show page", true
      
    #Edits
      include_examples "has an edit page", true

    #Posts
      include_examples "can post update", true, :name

    #Delete
      include_examples "can delete a record", true
  end
   
end


