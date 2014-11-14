require 'rails_helper'

describe SeasonsController do
  #Authenticate
  before :each do
    activate_authlogic
  end
  
  context 'public access to seasons' do
    before :each do
      @user = create(:user, security: "0")
      UserSession.create(@user)
    end
    
    #Shows
      include_examples 'has an index page', "season", true
      include_examples "has a show page", "season", true
      
    #Edits
      include_examples "has a new page", "season", false
      include_examples "has an edit page", "season", false

    #Posts
      include_examples "can post create", "season", false
      include_examples "can post update", "season", false, :name

    #Delete
      include_examples "can delete a record", "season", false
      
  end
  
  context 'user access to seasons' do
    before :each do
      @user = create(:user)
      UserSession.create(@user)
    end
    
    #Shows
      include_examples 'has an index page', "season", true
      include_examples "has a show page", "season", true
      
    #Edits
      include_examples "has a new page", "season", false
      include_examples "has an edit page", "season", false

    #Posts
      include_examples "can post create", "season", false
      include_examples "can post update", "season", false, :name

    #Delete
      include_examples "can delete a record", "season", false
  end

  context 'admin access to seasons' do
    before :each do
      @user = create(:admin)
      UserSession.create(@user)
    end
    
    #Shows
      include_examples 'has an index page', "season", true
      include_examples "has a show page", "season", true
      
    #Edits
      include_examples "has a new page", "season", true
      include_examples "has an edit page", "season", true

    #Posts
      include_examples "can post create", "season", true
      include_examples "can post update", "season", true, :name

    #Delete
      include_examples "can delete a record", "season", true
  end
   
end


