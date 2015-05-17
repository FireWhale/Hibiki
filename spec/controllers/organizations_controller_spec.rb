require 'rails_helper'

describe OrganizationsController do
  #Authenticate
  before :each do
    activate_authlogic
  end
  
  context 'public access to organizations' do

    #Ajax
      include_examples "can autocomplete", true, :search
      include_examples "can autocomplete", false, :edit
      
    #Shows
      include_examples 'has an index page', true, :internal_name
      include_examples "has a show page", true
      include_examples "has an images page", true, :show_images
      
    #Edits
      include_examples "has a new page", false
      include_examples "has an edit page", false

    #Posts
      include_examples "can post create", false
      include_examples "can post update", false, :internal_name

    #Delete
      include_examples "can delete a record", false
            
  end
  
  context 'user access to organizations' do
    before :each do
      @user = create(:user)
      UserSession.create(@user)
    end
    
    #Ajax
      include_examples "can autocomplete", true, :search
      include_examples "can autocomplete", false, :edit
      
    #Shows
      include_examples 'has an index page', true, :internal_name
      include_examples "has a show page", true
      include_examples "has an images page", true, :show_images
      
    #Edits
      include_examples "has a new page", false
      include_examples "has an edit page", false

    #Posts
      include_examples "can post create", false
      include_examples "can post update", false, :internal_name

    #Delete
      include_examples "can delete a record", false

  end

  context 'admin access to organizations' do
    before :each do
      @user = create(:admin)
      UserSession.create(@user)
    end
    
    #Ajax
      include_examples "can autocomplete", true, :search
      include_examples "can autocomplete", true, :edit
      
    #Shows
      include_examples 'has an index page', true, :internal_name
      include_examples "has a show page", true
      include_examples "has an images page",true, :show_images
      
    #Edits
      include_examples "has a new page", true
      include_examples "has an edit page", true

    #Posts
      include_examples "can post create", true
      include_examples "can post update", true, :internal_name

    #Delete
      include_examples "can delete a record", true
  end
   
end


