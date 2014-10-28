require 'rails_helper'

describe AlbumsController do
  #Authenticate
  before :each do
    activate_authlogic
    @user = create(:admin)
    UserSession.create(@user)
  end
  
  shared_examples_for 'public access to albums' do
    #Gets
      describe 'GET #index' do
        it "populates an array of paged albums"
        it 'renders the :index template' do
          get :index
          expect(response).to render_template :index
        end
      end
      
      describe 'GET #show' do
        it "assigns the requested album to @album" do
          album = create(:album)
          get :show, id: album
          expect(assigns(:album)).to eq album
        end
        it "renders the :show template" do
          album = create(:album)
          get :show, id: album
          expect(response).to render_template :show   
        end
      end
  end
  

    
    describe 'GET #new' do
      it "assigns a new album to @album" do
        get :new
        expect(assigns(:album)).to be_a_new(Album)
      end
      it "renders the :new template" do
        get :new
        expect(response).to render_template :new
      end
      
    end
    
    describe 'GET #edit' do
      it "assigns the requested contact to @contact" do
        album = create(:album)
        get :edit, id: album
        expect(assigns(:album)).to eq album
      end
      it "renders the :edit template" do
        album = create(:album)
        get :edit, id: album
        expect(response).to render_template :edit
      end
    end
  
  #Posts
    describe 'POST #create' do
      
      context "with valid attributes" do
        it "saves the new album in the database" do
          expect{post :create, album: attributes_for(:album)
          }.to change(Album, :count).by(1)
        end
        it "redirects to albums#show" do
          post :create, album: attributes_for(:album)
          expect(response).to redirect_to album_path(assigns[:album])
        end
      end
      
      context "with invalid attributes" do
        it "does not save the new contact in the database"
        it "re-renders the :new template"
      end
    end
  
    describe 'PUT #update' do
      before :each do
        @album = create(:album, name: 'hi', status: 'unreleased', catalognumber: '111')
      end
      
      context "with valid attributes" do
        it "locates the requested @album" do
          put :update, id: @album, album: attributes_for(:album)
          expect(assigns(:album)).to eq(@album)
        end
        
        it "updates the album in the database" do
          put :update, id: @album, album: attributes_for(:album, name: 'hello')
          @album.reload
          expect(@album.name).to eq('hello')
        end
        
        it "redirects to the album" do
          put :update, id: @album, album: attributes_for(:album)
          expect(response).to redirect_to @album
        end
      end
      
      context "with invalid attributes" do
        it "does not update the album" do
          put :update, id: @album, album: attributes_for(:album, name: '')
          @album.reload
          expect(@album.name).not_to eq('')
        end
        it "re-renders the #edit template" do
          put :update, id: @album, album: attributes_for(:album, name: '')
          expect(response).to render_template :edit
        end
      end
    end  
    
    describe 'DELETE #destroy' do
      before :each do
        @album = create(:album)
      end
      
      it "destroys the album from the database" do
        expect{delete :destroy, id: @album}.to change(Album,:count).by(-1)
      end
      it "redirects to album#index" do
        delete :destroy, id: @album
        expect(response).to redirect_to albums_url
      end
    end
end
