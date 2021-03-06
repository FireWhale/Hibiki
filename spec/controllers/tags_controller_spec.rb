require 'rails_helper'

describe TagsController do
  include_examples "global controller tests" #Global Tests

  #Authenticate
  before :each do
    activate_authlogic
  end
  
  context 'public access to tags' do          
    #Shows
      include_examples 'has an index page', true, :classification
      include_examples "has a show page", true
      
    #Edits
      include_examples "has a new page", false
      include_examples "has an edit page", false

    #Posts
      include_examples "can post create", false
      include_examples "can post update", false, :classification

    #Delete
      include_examples "can delete a record", false

    #Strong Parameters
      include_examples "uses strong parameters", invalid_params: [["tag_models"]]
  end
  
  context 'user access to tags' do
    before :each do
      @user = create(:user, :user_role)
      UserSession.create(@user)
    end
          
    #Shows
      include_examples 'has an index page', true, :classification
      include_examples "has a show page", true
      
    #Edits
      include_examples "has a new page", false
      include_examples "has an edit page", false

    #Posts
      include_examples "can post create", false
      include_examples "can post update", false, :classification

    #Delete
      include_examples "can delete a record", false
      
    #Strong Parameters
      include_examples "uses strong parameters", invalid_params: [["tag_models"]]
  end

  context 'admin access to tags' do
    before :each do
      @user = create(:user, :admin_role)
      UserSession.create(@user)
    end
          
    #Shows
      include_examples 'has an index page', true, :classification
      include_examples "has a show page", true
      
    #Edits
      include_examples "has a new page", true
      include_examples "has an edit page", true

    #Posts
      include_examples "can post create", true
      include_examples "can post update", true, :classification

    #Delete
      include_examples "can delete a record", true

    #Strong Parameters
      include_examples "uses strong parameters", valid_params: ["internal_name", "classification", "visibility", ["tag_models"],
       {"name_langs" => "string"},["new_name_langs"], ["new_name_lang_categories"],
       {"info_langs" => "string"},["new_info_langs"], ["new_info_lang_categories"]]
  end
end


