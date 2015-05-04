require 'rails_helper'

describe UsersController do
  #DON'T DELETE UNTIL TEST IS ADDED
  #test the post update_profile to make sure no one, not even admins
  #can post to a different user. The GETS are already filtered out for admins
  #in the HTML, but the posts still need to be filtered out, maybe at the controller
  #level such as:
  #@user = User.find(params[:id])
  #if current_user == @user
  #do stuff
  #end

  #Authenticate
  before :each do
    activate_authlogic
  end
  

  context 'public access to users' do
    before :each do
      @user = create(:user, security: "0")
      UserSession.create(@user)
    end
    
  end
  
  context 'user access to artists' do
    before :each do
      @user = create(:user)
      UserSession.create(@user)
    end
    
  end

  context 'admin access to artists' do
    before :each do
      @user = create(:admin)
      UserSession.create(@user)
    end
    
  end
end


