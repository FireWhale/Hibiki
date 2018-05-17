require 'rails_helper'

describe PostsController do

  #Authenticate
  before :each do
    activate_authlogic
  end
  
  context 'public access to posts' do
          
    #Shows
      include_examples 'has an index page', true, :id #id is basically created_at
      include_examples "has a show page", true
      include_examples "has an images page", false, :show_images
      
    #Edits
      include_examples "has a new page", false
      include_examples "has an edit page", false

    #Posts
      include_examples "can post create", false
      include_examples "can post update", false, :content

    #Delete
      include_examples "can delete a record", false
      
    #Strong Parameters
      include_examples "uses strong parameters"
  end
  
  context 'user access to posts' do
    before :each do
      @user = create(:user)
      UserSession.create(@user)
    end
    
      
    #Shows
      include_examples 'has an index page', true, :id #id is basically created_at
      include_examples "has a show page", true
      include_examples "has an images page", false, :show_images
      
    #Edits
      include_examples "has a new page", false
      include_examples "has an edit page", false

    #Posts
      include_examples "can post create", false
      include_examples "can post update", false, :content

    #Delete
      include_examples "can delete a record", false
      
   #Strong Parameters
      include_examples "uses strong parameters"
  end

  context 'admin access to posts' do
    before :each do
      @user = create(:admin)
      UserSession.create(@user)
    end
      
    #Shows
      include_examples 'has an index page', true, :id #id is basically created_at
      include_examples "has a show page", true
      include_examples "has an images page",true, :show_images
      
    #Edits
      include_examples "has a new page", true
      include_examples "has an edit page", true

    #Posts
      include_examples "can post create", true
      include_examples "can post update", true, :content

    #Delete
      include_examples "can delete a record", true

   #Strong Parameters
      include_examples "uses strong parameters", valid_params: ["category", "content", "visibility","title", "status", ["new_images"]],
                                                     invalid_params: ["id", "timestamp", "created_at", "updated_at" ]
  end
   
end


