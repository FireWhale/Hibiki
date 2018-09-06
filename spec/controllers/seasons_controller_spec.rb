require 'rails_helper'

describe SeasonsController do
  #Authenticate
  before :each do
    activate_authlogic
  end
  
  context 'public access to seasons' do    
    #Shows
      include_examples 'has an index page', true, :start_date
      include_examples "has a show page", true
      include_examples "has an images page", false, :show_images
      
    #Edits
      include_examples "has a new page", false
      include_examples "has an edit page", false

    #Posts
      include_examples "can post create", false
      include_examples "can post update", false, :name

    #Delete
      include_examples "can delete a record", false
      
    #Strong Parameters
      include_examples "uses strong parameters", invalid_params: [["remove_source_seasons"], {"new_sources" => {"new" => ["id", "category"]}},{"update_source_seasons" => {"update" => ["category"]}}]

  end
  
  context 'user access to seasons' do
    before :each do
      @user = create(:user, :user_role)
      UserSession.create(@user)
    end
    
    #Shows
      include_examples 'has an index page', true, :start_date
      include_examples "has a show page", true
      include_examples "has an images page", false, :show_images
      
    #Edits
      include_examples "has a new page", false
      include_examples "has an edit page", false

    #Posts
      include_examples "can post create", false
      include_examples "can post update", false, :name

    #Delete
      include_examples "can delete a record", false
      
    #Strong Parameters
      include_examples "uses strong parameters", invalid_params: [["remove_source_seasons"], {"new_sources" => {"new" => ["id", "category"]}},{"update_source_seasons" => {"update" => ["category"]}}]

  end

  context 'admin access to seasons' do
    before :each do
      @user = create(:user, :admin_role)
      UserSession.create(@user)
    end
    
    #Shows
      include_examples 'has an index page', true, :start_date
      include_examples "has a show page", true
      include_examples "has an images page",true, :show_images
      
    #Edits
      include_examples "has a new page", true
      include_examples "has an edit page", true

    #Posts
      include_examples "can post create", true
      include_examples "can post update", true, :name

    #Delete
      include_examples "can delete a record", true
      
    #Strong Parameters
      include_examples "uses strong parameters", valid_params: ["name", "start_date", "end_date",  ["new_images"],
                                                  ["remove_source_seasons"], {"new_sources" => {"new" => ["id", "category"]}},{"update_source_seasons" => {"update" => ["category"]}}]
      
  end
  
end


