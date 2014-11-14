require 'rails_helper'

describe AlbumsController do
  shared_examples "has an edit_tracklist page" do |valid|
    describe 'GET #edit_tracklist' do
      it "populates an album record" do
        album = create(:album)
        get :edit_tracklist, id: album
        expect(assigns(:album)).to eq album
      end
       
      it "renders the :edit_tracklist template" do
        album = create(:album)
        get :edit_tracklist, id: album
        valid_permissions(:edit_tracklist, valid)
      end
    end
  end
   
  shared_examples "can post update_tracklist" do |valid|
    describe 'POST #update_tracklist' do
      if valid == true
        it "locates the album" do
          album = create(:album)
          put :update_tracklist, id: album.id
          expect(assigns(:album)).to eq album
        end
        
        
        it "locates the songs"
        
        it "updates each song"
        
        it "redirects to the album"
      elsif valid == false
        it "does not update any songs"
        
        it "redirects to the album"
      else
        Raise Exception
      end
    end
    
  end  

  shared_examples "can get album_preview" do |valid|
    describe 'GET #album_preview' do
      it "locates the requested album" do
        album = create(:album)
          get "album_preview", id: album.id
        expect(assigns(:album)).to eq album
      end
      
      describe 'javascript response' do
        it "renders a view"
      end
      
      describe 'html response' do
        it "redirects to the album"
      end
      
    end
  end
  
  shared_examples "can post rescrape" do |valid|
    describe 'POST #rescrapte' do
      if valid == true
        it "locates the requested album"  do
          album = create(:album)
          put :rescrape, id: album.id
          expect(assigns(:album)).to eq album
        end
        
        it "performs a rescrape"
        
        it "redirects to the album"
        
      elsif valid == false
        
        it "does not perform a rescrape"
        
        it "redirects to the album"
        
      else
        Raise Exception
      end
    end
  end

  #Authenticate
  before :each do
    activate_authlogic
  end
  
  context 'public access to albums' do
    before :each do
      @user = create(:user, security: "0")
      UserSession.create(@user)
    end
    
    #Shows
      include_examples 'has an index page', "album", true
      include_examples "has a show page", "album", true
      include_examples "has an images page", "album", true, :album_art
      include_examples "can get album_preview", true
      
    #Edits
      include_examples "has a new page", "album", false
      include_examples "has an edit page", "album", false
      include_examples "has an edit_tracklist page", false

    #Posts
      include_examples "can post create", "album", false
      include_examples "can post update", "album", false, :name
      include_examples "can post update_tracklist", false
      include_examples "can post rescrape", false

    #Delete
      include_examples "can delete a record", "album", false
      
  end
  
  context 'user access to albums' do
    before :each do
      @user = create(:user)
      UserSession.create(@user)
    end

    
    #Shows
      include_examples 'has an index page', "album", true
      include_examples "has a show page", "album", true
      include_examples "has an images page", "album", true, :album_art
      include_examples "can get album_preview", true
      
    #Edits
      include_examples "has a new page", "album", false
      include_examples "has an edit page", "album", false
      include_examples "has an edit_tracklist page", false
      
    #Posts
      include_examples "can post create", "album", false
      include_examples "can post update", "album", false, :name
      include_examples "can post update_tracklist", false
      include_examples "can post rescrape", false
    
    #Delete
      include_examples "can delete a record", "album", false
          
  end

  context 'admin access to albums' do
    before :each do
      @user = create(:admin)
      UserSession.create(@user)
    end
    
    #Shows
      include_examples 'has an index page', "album", true
      include_examples "has a show page", "album", true
      include_examples "has an images page", "album", true, :album_art
      include_examples "can get album_preview", true
      
    #Edits
      include_examples "has a new page", "album", true
      include_examples "has an edit page", "album", true
      include_examples "has an edit_tracklist page", true
      
    #Posts
      include_examples "can post create", "album", true
      include_examples "can post update", "album", true, :name
      include_examples "can post update_tracklist", true
      include_examples "can post rescrape", false
    
    #Delete
      include_examples "can delete a record", "album", true
      
  end
   
end


