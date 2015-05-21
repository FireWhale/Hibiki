require 'rails_helper'
require 'sidekiq/testing'
Sidekiq::Testing.fake!

describe AlbumsController do
  shared_examples "has an edit_tracklist page" do |accessible|
    describe 'GET #edit_tracklist' do
      
      it "populates an album record" do
        album = create(:album)
        get :edit_tracklist, id: album
        expect(assigns(:album)).to eq album
      end
      
      it "responds to json" do
        album = create(:album)
        get :edit_tracklist, id: album, format: :json
        if accessible == true
          expect(response.body).to eq(album.to_json)
        else
          expect(response.status).to eq(403)
        end
      end
       
      it "renders the :edit_tracklist template" do
        album = create(:album)
        get :edit_tracklist, id: album
        valid_permissions(:edit_tracklist, accessible)
      end
    end
  end
   
  shared_examples "can post update_tracklist" do |accessible|
    describe 'POST #update_tracklist' do
      if accessible == true
        it "locates the album" do
          album = create(:album, :with_songs)
          put :update_tracklist, id: album.id
          expect(assigns(:album)).to eq album
        end
                
        it "updates each song in the album" do
          album = create(:album, :with_songs)
          new_info = attributes_for(:song, internal_name: "hohoho")
          song_info = {album.songs.first.id => new_info}
          put :update_tracklist, id: album.id, song: song_info
          expect(album.songs.first.reload.internal_name).to eq("hohoho")
        end
                
        it "redirects to the album" do
          album = create(:album, :with_songs)
          put :update_tracklist, id: album.id
          expect(response).to redirect_to album_path(assigns[:album])
        end
        
        it "responds to json" do
          album = create(:album, :with_songs)
          put :update_tracklist, id: album.id, format: :json
          expect(response.status).to eq(204) #204 No Content -> ajax success event
        end
      else
        it "does not update any songs" do
          album = create(:album, :with_songs)
          new_info = attributes_for(:song, name: "hohoho")
          song_info = {album.songs.first.id => new_info}
          put :update_tracklist, id: album.id, song: song_info
          expect(album.songs.first.reload.name).to_not eq("hohoho")
        end
        
        it "redirects to the access denied" do
          album = create(:album, :with_songs)
          put :update_tracklist, id: album.id
          expect(response).to render_template("pages/access_denied")
        end
      end
    end
  end
  
  shared_examples "can post rescrape" do |accessible|
    describe 'POST #rescrape' do
      before(:each) do
        Sidekiq::Worker.clear_all
      end
      
      if accessible == true
        it "locates the album" do
          album = create(:album, :with_reference)
          post = create(:post, category: "Rescrape Result", content: "hi")
          put :rescrape, id: album.id
          expect(assigns(:album)).to eq(album)
        end
        
        it "locates the rescrape post" do
          album = create(:album, :with_reference)
          post = create(:post, category: "Rescrape Result", content: "hi")
          put :rescrape, id: album.id
          expect(assigns(:post)).to eq(post)
        end
        
        it "sends off a sidekiq request" do
          album = create(:album, :with_reference)
          post = create(:post, category: "Rescrape Result", content: "hi")
          expect{put :rescrape, id: album.id}.to change(ScrapeWorker.jobs, :size).by(1)
        end
        
        it "redirects to the album" do
          album = create(:album, :with_reference)
          post = create(:post, category: "Rescrape Result", content: "hi")
          put :rescrape, id: album.id
          expect(response).to redirect_to album_path(assigns[:album])
        end
        
        it "responds to json" do
          album = create(:album, :with_reference)
          post = create(:post, category: "Rescrape Result", content: "hi")
          put :rescrape, id: album.id, format: :json
          expect(response.status).to eq(204) #204 No Content -> ajax success event          
        end
        
      else        
        it "does not send off a sidekiq requset" do
          album = create(:album, :with_reference)
          post = create(:post, category: "Rescrape Result", content: "hi")
          expect{put :rescrape, id: album.id}.to change(ScrapeWorker.jobs, :size).by(0)
        end
        
        it "redirects to the access denied" do
          album = create(:album, :with_reference)
          post = create(:post, category: "Rescrape Result", content: "hi")
          put :rescrape, id: album.id
          expect(response).to render_template("pages/access_denied")
        end
      end
    end
      
  end
    
  
  #Authenticate
  before :each do
    activate_authlogic
  end
  
  context 'public access to albums' do          
    #Shows
      include_examples 'has an index page', true, :release_date
      include_examples "has a show page", true
      include_examples "has an images page", true, :album_art
      
    #Edits
      include_examples "has a new page", false
      include_examples "has an edit page", false
      include_examples "has an edit_tracklist page", false

    #Posts
      include_examples "can post create", false
      include_examples "can post update", false, :internal_name
      include_examples "can post update_tracklist", false
      include_examples "can post rescrape", false

    #Delete
      include_examples "can delete a record", false      
  end
  
  context 'user access to albums' do
    before :each do
      @user = create(:user)
      UserSession.create(@user)
    end    
      
    #Shows
      include_examples 'has an index page', true, :release_date
      include_examples "has a show page", true
      include_examples "has an images page", true, :album_art
      
    #Edits
      include_examples "has a new page", false
      include_examples "has an edit page", false
      include_examples "has an edit_tracklist page", false

    #Posts
      include_examples "can post create", false
      include_examples "can post update", false, :internal_name
      include_examples "can post update_tracklist", false
      include_examples "can post rescrape", false

    #Delete
      include_examples "can delete a record", false
      

  end

  context 'admin access to albums' do
    before :each do
      @user = create(:admin)
      UserSession.create(@user)
    end
          
    #Shows
      include_examples 'has an index page', true, :release_date
      include_examples "has a show page", true
      include_examples "has an images page",true, :album_art
      
    #Edits
      include_examples "has a new page", true
      include_examples "has an edit page", true
      include_examples "has an edit_tracklist page", true

    #Posts
      include_examples "can post create", true
      include_examples "can post update", true, :internal_name
      include_examples "can post update_tracklist", true
      include_examples "can post rescrape", true

    #Delete
      include_examples "can delete a record", true
  end
        
end


