require 'rails_helper'

describe EventsController do
  #Authenticate
  before :each do
    activate_authlogic
  end
  
  describe 'public access to events' do
    #Shows
      include_examples 'has an index page', true, :start_date
      include_examples "has a show page", true
      
    #Edits
      include_examples "has a new page", false
      include_examples "has an edit page", false

    #Posts
      include_examples "can post create", false
      include_examples "can post update", false, :internal_name

    #Delete
      include_examples "can delete a record", false
      
    #Strong Parameters
      include_examples "uses strong parameters"
      
  end
  
  describe 'user access to events' do
    before :each do
      @user = create(:user)
      UserSession.create(@user)
    end
    
    #Shows
      include_examples 'has an index page', true, :start_date
      include_examples "has a show page", true
      
    #Edits
      include_examples "has a new page", false
      include_examples "has an edit page", false

    #Posts
      include_examples "can post create", false
      include_examples "can post update", false, :internal_name

    #Delete
      include_examples "can delete a record", false
      
    #Strong Parameters
      include_examples "uses strong parameters"
      
  end

  describe 'admin access to events' do
    before :each do
      @user = create(:admin)
      UserSession.create(@user)
    end
    
    #Shows
      include_examples 'has an index page', true, :start_date
      include_examples "has a show page", true
      
    #Edits
      include_examples "has a new page", true
      include_examples "has an edit page", true

    #Posts
      include_examples "can post create", true
      include_examples "can post update", true, :internal_name

    #Delete
      include_examples "can delete a record", true
      
    #Strong Parameters
      include_examples "uses strong parameters", valid_params: ["internal_name", "shorthand", "db_status","start_date", "end_date",
                                                  {"name_langs" => "string"},["new_name_langs"], ["new_name_lang_categories"],
                                                  {"abbreviation_langs" => "string"},["new_abbreviation_langs"], ["new_abbreviation_lang_categories"],
                                                  {"info_langs" => "string"},["new_info_langs"], ["new_info_lang_categories"],
                                                  {"new_references" => {"new" => ["site_name", "url"]}}, {"update_references" => {"update" => ["url", "site_name"]}}]
  end
   
end


