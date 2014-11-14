require 'rails_helper'

describe ArtistsController do


  shared_examples "can add_an_artist_to_song" do |valid|
    
  end  

  #Authenticate
  before :each do
    activate_authlogic
  end
  
  context 'public access to artists' do
    before :each do
      @user = create(:user, security: "0")
      UserSession.create(@user)
    end
    
    #Shows
      include_examples 'has an index page', "artist", true
      include_examples "has a show page", "artist", true
      include_examples "has an images page", "artist", true, :show_images
      
    #Edits
      include_examples "has a new page", "artist", false
      include_examples "has an edit page", "artist", false
      include_examples "can add_an_artist_to_song", false

    #Posts
      include_examples "can post create", "artist", false
      include_examples "can post update", "artist", false, :name

    #Delete
      include_examples "can delete a record", "artist", false
      
  end
  
  context 'user access to artists' do
    before :each do
      @user = create(:user)
      UserSession.create(@user)
    end
    
    #Shows
      include_examples 'has an index page', "artist", true
      include_examples "has a show page", "artist", true
      include_examples "has an images page", "artist", true, :show_images
      
    #Edits
      include_examples "has a new page", "artist", false
      include_examples "has an edit page", "artist", false
      include_examples "can add_an_artist_to_song", false

    #Posts
      include_examples "can post create", "artist", false
      include_examples "can post update", "artist", false, :name

    #Delete
      include_examples "can delete a record", "artist", false

  end

  context 'admin access to artists' do
    before :each do
      @user = create(:admin)
      UserSession.create(@user)
    end
    
    #Shows
      include_examples 'has an index page', "artist", true
      include_examples "has a show page", "artist", true
      include_examples "has an images page", "artist", true, :show_images
      
    #Edits
      include_examples "has a new page", "artist", true
      include_examples "has an edit page", "artist", true
      include_examples "can add_an_artist_to_song", true

    #Posts
      include_examples "can post create", "artist", true
      include_examples "can post update", "artist", true, :name

    #Delete
      include_examples "can delete a record", "artist", true
  end
   
end


