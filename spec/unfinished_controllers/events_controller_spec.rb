require 'rails_helper'

describe EventsController do

  #Authenticate
  before :each do
    activate_authlogic
  end
  
  context 'public access to events' do
    before :each do
      @user = create(:user, security: "0")
      UserSession.create(@user)
    end
    
    #Shows
      include_examples 'has an index page', "event", true
      include_examples "has a show page", "event", true
      
    #Edits
      include_examples "has a new page", "event", false
      include_examples "has an edit page", "event", false

    #Posts
      include_examples "can post create", "event", false
      include_examples "can post update", "event", false, :name

    #Delete
      include_examples "can delete a record", "event", false
      
  end
  
  context 'user access to artists' do
    before :each do
      @user = create(:user)
      UserSession.create(@user)
    end
    
    #Shows
      include_examples 'has an index page', "event", true
      include_examples "has a show page", "event", true
      
    #Edits
      include_examples "has a new page", "event", false
      include_examples "has an edit page", "event", false

    #Posts
      include_examples "can post create", "event", false
      include_examples "can post update", "event", false, :name

    #Delete
      include_examples "can delete a record", "event", false

  end

  context 'admin access to artists' do
    before :each do
      @user = create(:admin)
      UserSession.create(@user)
    end
    
    #Shows
      include_examples 'has an index page', "event", true
      include_examples "has a show page", "event", true
      
    #Edits
      include_examples "has a new page", "event", true
      include_examples "has an edit page", "event", true

    #Posts
      include_examples "can post create", "event", true
      include_examples "can post update", "event", true, :name

    #Delete
      include_examples "can delete a record", "event", true
  end
   
end


