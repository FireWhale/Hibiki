require 'rails_helper'

describe SongsController do

  #Authenticate
  before :each do
    activate_authlogic
  end
  
  context 'public access to songs' do      
    #Shows
      include_examples 'has an index page', true, :id
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
      include_examples "uses strong parameters", invalid_params: ["internal_name", "namehash", "status", "release_date", "track_number", "disc_number",
        "length", "synonyms", ["new_images"],["remove_related_songs"], ["remove_song_sources"], {"info_langs" => "string"},["new_info_langs"], ["new_info_lang_categories"],
        {"name_langs" => "string"},["new_name_langs"], ["new_name_lang_categories"],
        {"lyrics_langs" => "string"},["new_lyrics_langs"], ["new_lyrics_lang_categories"],
        {"new_artists" => {"new" => ["id", "category"]}}, {"update_artist_songs" => {"update" => [["category"]]}},
        {"new_sources" => {"new" => ["id", "classification", "op_ed_number", "ep_numbers"]}}, {"update_song_sources" => {"update" => ["classification", "op_ed_number", "ep_numbers"]}},
        {"new_related_songs" => {"new" => ["id", "category"]}}, {"update_related_songs" => {"update" => ["category"]}},
        {"new_references" => {"new" => ["site_name", "url"]}}, {"update_references" => {"update" => ["url", "site_name"]}}]
  end
  
  context 'user access to songs' do
    before :each do
      @user = create(:user)
      UserSession.create(@user)
    end
          
    #Shows
      include_examples 'has an index page', true, :id
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
      include_examples "uses strong parameters", invalid_params: ["internal_name", "namehash", "status", "release_date", "track_number", "disc_number",
        "length", "synonyms", ["new_images"],["remove_related_songs"], ["remove_song_sources"], {"info_langs" => "string"},["new_info_langs"], ["new_info_lang_categories"],
        {"name_langs" => "string"},["new_name_langs"], ["new_name_lang_categories"],
        {"lyrics_langs" => "string"},["new_lyrics_langs"], ["new_lyrics_lang_categories"],
        {"new_artists" => {"new" => ["id", "category"]}}, {"update_artist_songs" => {"update" => [["category"]]}},
        {"new_sources" => {"new" => ["id", "classification", "op_ed_number", "ep_numbers"]}}, {"update_song_sources" => {"update" => ["classification", "op_ed_number", "ep_numbers"]}},
        {"new_related_songs" => {"new" => ["id", "category"]}}, {"update_related_songs" => {"update" => ["category"]}},
        {"new_references" => {"new" => ["site_name", "url"]}}, {"update_references" => {"update" => ["url", "site_name"]}}]
  end

  context 'admin access to songs' do
    before :each do
      @user = create(:admin)
      UserSession.create(@user)
    end
      
    #Shows
      include_examples 'has an index page', true, :id
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
      include_examples "uses strong parameters", valid_params: ["internal_name", "info", "private_info", "status", "release_date", "track_number", "disc_number",
        "length", "synonyms", ["new_images"],["remove_related_songs"], ["remove_song_sources"], {"namehash" => "string"},
        {"info_langs" => "string"},["new_info_langs"], ["new_info_lang_categories"],
        {"name_langs" => "string"},["new_name_langs"], ["new_name_lang_categories"],
        {"lyrics_langs" => "string"},["new_lyrics_langs"], ["new_lyrics_lang_categories"],
        {"new_artists" => {"new" => ["id", "category"]}}, {"update_artist_songs" => {"update" => [["category"]]}},
        {"new_sources" => {"new" => ["id", "classification", "op_ed_number", "ep_numbers"]}}, {"update_song_sources" => {"update" => ["classification", "op_ed_number", "ep_numbers"]}},
        {"new_related_songs" => {"new" => ["id", "category"]}}, {"update_related_songs" => {"update" => ["category"]}},
        {"new_references" => {"new" => ["site_name", "url"]}}, {"update_references" => {"update" => ["url", "site_name"]}}]

  end
end


