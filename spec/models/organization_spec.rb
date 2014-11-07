require 'rails_helper'

describe Organization do
  #Gutcheck Test
    it "has a valid factory" do
      instance = create(:organization)
      expect(instance).to be_valid
    end
  
  #Shared Examples
    it_behaves_like "it has images", :organization, Organization
    it_behaves_like "it has tags", :organization, Organization
    it_behaves_like "it has posts", :organization, Organization
    it_behaves_like "it has watchlists", :organization, Organization
    it_behaves_like "it can be searched", :organization, Organization
    it_behaves_like "it can be autocompleted", :organization
    it_behaves_like "it has pagination", "organization"

  #Association Tests - a lot of em ( ﾟдﾟ)
    it_behaves_like "it has self-relations", :organization, "organization", RelatedOrganizations
    it_behaves_like "it has a primary relation", :organization, "album", AlbumOrganization, :album_organization
    it_behaves_like "it has a primary relation", :organization, "source", SourceOrganization, :source_organization
    it_behaves_like "it has a primary relation", :organization, "artist", ArtistOrganization, :artist_organization
    
  #Validation Tests
    include_examples "is invalid without an attribute", :organization, :name
    include_examples "is invalid without an attribute", :organization, :status
    include_examples "name/reference combinations", :organization
    
    include_examples "is invalid without an attribute in a category", :organization, :status, Album::Status, "Album::Status"
    include_examples "is invalid without an attribute in a category", :organization, :db_status, Artist::DatabaseStatus, "Artist::DatabaseStatus"
    include_examples "is invalid without an attribute in a category", :organization, :activity, Organization::Activity, "Organization::Activity"
    include_examples "is invalid without an attribute in a category", :organization, :category, Organization::Categories, "Organization::Categories"

    include_examples "redirects to a new record when db_status is hidden", :organization, "something"

    include_examples "is valid with or without an attribute", :organization, :altname, "hi"
    include_examples "is valid with or without an attribute", :organization, :db_status, "Complete"
    include_examples "is valid with or without an attribute", :organization, :activity, Organization::Activity.sample
    include_examples "is valid with or without an attribute", :organization, :category, Organization::Categories.sample
    include_examples "is valid with or without an attribute", :organization, :info, "Hi this is info"
    include_examples "is valid with or without an attribute", :organization, :private_info, "Hi this is private info"
    include_examples "is valid with or without an attribute", :organization, :synopsis, "Hi this is a synopsis"
    include_examples "is valid with or without an attribute", :organization, :popularity, 55
    
    it_behaves_like "it has a partial date", :organization, :established
          
  #Serialization Tests
    it_behaves_like "it has a serialized attribute", :organization, :reference
    it_behaves_like "it has a serialized attribute", :organization, :namehash
    

  #Instance Method Tests
    
  #Class Method Tests    
    context "has a full update method" do
      include_examples "updates with keys and values", :organization
      include_examples "updates the reference properly", :organization
      include_examples "can upload an image", :organization
      include_examples "can update a primary relationship", :organization, :artist, ArtistOrganization, "artist_organization"
      include_examples "can update self-relations", :organization
      include_examples "updates dates properly", :organization, "established"
      include_examples "updates with normal attributes", :organization
      
    end   
    
    
  #Scope Tests
    it_behaves_like "it reports released records", :organization
    
end


