require 'rails_helper'

describe IssuesController do
  #Authenticate
  before :each do
    activate_authlogic
  end
  
  context 'public access to issues' do
    before :each do
      @user = create(:user, security: "0")
      UserSession.create(@user)
    end
    
    #Shows
      include_examples 'has an index page', "issue", false
      include_examples "has a show page", "issue", false
      
    #Edits
      include_examples "has a new page", "issue", false
      include_examples "has an edit page", "issue", false

    #Posts
      include_examples "can post create", "issue", false
      include_examples "can post update", "issue", false, :name

    #Delete
      include_examples "can delete a record", "issue", false
      
  end
  
  context 'user access to artists' do
    before :each do
      @user = create(:user)
      UserSession.create(@user)
    end
    
    #Shows
      include_examples 'has an index page', "issue", true
      include_examples "has a show page", "issue", true
      
    #Edits
      include_examples "has a new page", "issue", false
      include_examples "has an edit page", "issue", false

    #Posts
      include_examples "can post create", "issue", false
      include_examples "can post update", "issue", false, :name

    #Delete
      include_examples "can delete a record", "issue", false
      

  end

  context 'admin access to artists' do
    before :each do
      @user = create(:admin)
      UserSession.create(@user)
    end
    
    #Shows
      include_examples 'has an index page', "issue", true
      include_examples "has a show page", "issue", true
      
    #Edits
      include_examples "has a new page", "issue", true
      include_examples "has an edit page", "issue", true

    #Posts
      include_examples "can post create", "issue", true
      include_examples "can post update", "issue", true, :name

    #Delete
      include_examples "can delete a record", "issue", true
      
  end
   
end


