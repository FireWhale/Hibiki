require 'rails_helper'

describe OrganizationsController do
  #Authenticate
  before :each do
    activate_authlogic
  end
  
  context 'public access to organizations' do      
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

    #Strong Parameters
      include_examples "uses strong parameters", [],[
        "internal_name", "info", "private_info", "synonyms", "synopsis", "status", 
        "db_status", "activity", "category", "established", ["new_images"], ["remove_artist_organizations"], ["remove_related_organizations"], {"namehash" => "string"},
        {"name_langs" => "string"},["new_name_langs"], ["new_name_lang_categories"],
        {"info_langs" => "string"},["new_info_langs"], ["new_info_lang_categories"],
        {"new_related_organizations" => {"new" => ["id", "category"]}}, {"update_related_organizations" => {"update" => ["category"]}},
        {"new_artists" => {"new" => ["id", "category"]}}, {"update_artist_organizations" => {"update" => ["category"]}},        
        {"new_references" => {"new" => ["site_name", "url"]}}, {"update_references" => {"update" => ["url", "site_name"]}}]
            
  end
  
  context 'user access to organizations' do
    before :each do
      @user = create(:user)
      UserSession.create(@user)
    end
      
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

    #Strong Parameters
      include_examples "uses strong parameters", [],[
        "internal_name", "info", "private_info", "synonyms", "synopsis", "status", 
        "db_status", "activity", "category", "established", ["new_images"], ["remove_artist_organizations"], ["remove_related_organizations"], {"namehash" => "string"},
        {"name_langs" => "string"},["new_name_langs"], ["new_name_lang_categories"],
        {"info_langs" => "string"},["new_info_langs"], ["new_info_lang_categories"],
        {"new_related_organizations" => {"new" => ["id", "category"]}}, {"update_related_organizations" => {"update" => ["category"]}},
        {"new_artists" => {"new" => ["id", "category"]}}, {"update_artist_organizations" => {"update" => ["category"]}},        
        {"new_references" => {"new" => ["site_name", "url"]}}, {"update_references" => {"update" => ["url", "site_name"]}}]

  end

  context 'admin access to organizations' do
    before :each do
      @user = create(:admin)
      UserSession.create(@user)
    end
      
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

    #Strong Parameters
      include_examples "uses strong parameters", [
        "internal_name", "info", "private_info", "synonyms", "synopsis", "status", 
        "db_status", "activity", "category", "established", ["new_images"], ["remove_artist_organizations"], ["remove_related_organizations"], {"namehash" => "string"},
        {"name_langs" => "string"},["new_name_langs"], ["new_name_lang_categories"],
        {"info_langs" => "string"},["new_info_langs"], ["new_info_lang_categories"],
        {"new_related_organizations" => {"new" => ["id", "category"]}}, {"update_related_organizations" => {"update" => ["category"]}},
        {"new_artists" => {"new" => ["id", "category"]}}, {"update_artist_organizations" => {"update" => ["category"]}},        
        {"new_references" => {"new" => ["site_name", "url"]}}, {"update_references" => {"update" => ["url", "site_name"]}}], []

  end
   
end


