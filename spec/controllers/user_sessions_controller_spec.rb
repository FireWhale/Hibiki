require 'rails_helper'

describe UserSessionsController do  
  shared_examples "can post create user session" do |accessible|
    describe 'POST #create' do
      if accessible == true
        
        context 'with valid login credentials' do
          let(:user) {create(:user)}
          
          it "saves the new user_session" do
            post :create, params: {user_session: {:name => user.name, password: 'hehepassword1'}}
            expect(UserSession.find.record).to eq(user)
          end
          
          it "redirects to root" do #change eventually to last page? requires a cookie I think
            post :create, params: {user_session: {:name => user.name, password: 'hehepassword1'}}
            expect(response).to redirect_to :root
          end
          
          it "responds to json" do
            post :create, params: {user_session: {:name => user.name, password: 'hehepassword1'}}, format: :json
            expect(response.status).to eq(204) #204 No Content no content -> ajax success event            
          end         
        end
        
        context 'without valid login credentials' do
          let(:user) {create(:user)}
          
          it "does not save a user_session" do
            post :create, params: {user_session: {:name => user.name, password: 'wrong pass'}}
            if @user.nil?
              expect(UserSession.find).to be_nil
            else
              expect(UserSession.find.record).to_not eq(user)
            end
          end
          
          it "renders the new template" do
            post :create, params: {user_session: {:name => user.name, password: 'wrong pass'}}
            expect(response).to render_template(:new)
          end
          
          it "respond to json" do
            post :create, params: {user_session: {:name => user.name, password: 'wrong pass'}}, format: :json
            expect(response.status).to eq(422) #unprocessible entity            
          end
          
        end
        
      else
        it "does not save a new user_session" do
          user = create(:user)
          post :create, params: {user_session: {:name => user.name, password: 'hehepassword1'}}
          if @user.nil?
            expect(UserSession.find).to be_nil
          else
            expect(UserSession.find.record).to_not eq(user)
          end          
        end
        
        it "renders the access_denied template" do
          user = create(:user)
          post :create, params: {user_session: {:name => user.name, password: 'hehepassword1'}}
          expect(response).to render_template('pages/access_denied')
        end
      end
    end
  end
  
  shared_examples "can destroy a user_session" do |accessible|
    describe 'DELETE #destroy' do
      if accessible == true
        it "destroys the user_session" do
          delete :destroy
          expect(UserSession.find).to be_nil
        end
        
        it "redirects to root" do
          delete :destroy          
          expect(response).to redirect_to :root
        end
        
        it "renders success as json" do
          delete :destroy, format: :json
          expect(response.status).to eq(204) #success
        end
      else
        it "redirects to access denied" do
          delete :destroy
          expect(response).to render_template("pages/access_denied")
        end
      end
    end
  end
  
  before :each do
    activate_authlogic
  end
  
  context 'public access to users' do
    include_examples 'has a new page', true
    include_examples 'can post create user session', true
    include_examples 'can destroy a user_session', false
  end
  
  context 'user access to artists' do
    before :each do
      @user = create(:user, :user_role)
      UserSession.create(@user)
    end
    
    include_examples 'has a new page', false
    include_examples 'can post create user session', false
    include_examples 'can destroy a user_session', true
  end

  context 'admin access to artists' do
    before :each do
      @user = create(:user, :admin_role)
      UserSession.create(@user)
    end
    
    include_examples 'has a new page', true
    include_examples 'can post create user session', true
    include_examples 'can destroy a user_session', true
  end
end


