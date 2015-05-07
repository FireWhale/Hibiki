require 'rails_helper'

describe UserSessionsController do
  #Authenticate
  before :each do
    activate_authlogic
  end
  
  context 'public access to users' do
        
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


