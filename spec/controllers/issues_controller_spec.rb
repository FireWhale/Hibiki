require 'rails_helper'

describe IssuesController do
  #Authenticate
  before :each do
    activate_authlogic
  end
  
  context 'public access to issues' do
              
    #Shows
      include_examples 'has an index page', true, :id
      include_examples "has a show page", true
      
    #Edits
      include_examples "has a new page", false
      include_examples "has an edit page", false

    #Posts
      include_examples "can post create", false
      include_examples "can post update", false, :name

    #Delete
      include_examples "can delete a record", false
      
  end
  
   context 'user access to issues' do
    before :each do
      @user = create(:user)
      UserSession.create(@user)
    end
          
    #Shows
      include_examples 'has an index page', true, :id
      include_examples "has a show page", true
      
    #Edits
      include_examples "has a new page", false
      include_examples "has an edit page", false

    #Posts
      include_examples "can post create", false
      include_examples "can post update", false, :name

    #Delete
      include_examples "can delete a record", false
      

  end

  context 'admin access to issues' do
    before :each do
      @user = create(:admin)
      UserSession.create(@user)
    end
          
    #Shows
      include_examples 'has an index page', true, :id
      include_examples "has a show page", true
      
    #Edits
      include_examples "has a new page", true
      include_examples "has an edit page", true

    #Posts
      include_examples "can post create", true
      include_examples "can post update", true, :name

    #Delete
      include_examples "can delete a record", true
  end
   
end

