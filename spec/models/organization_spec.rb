require 'rails_helper'

describe Organization do
  include_examples "global model tests" #Global Tests
  
  #Module Tests
    it_behaves_like "it has a language field", :name
    it_behaves_like "it has a language field", :info
    it_behaves_like "it can be solr-searched"
    it_behaves_like "it can be autocompleted"
    it_behaves_like "it has pagination"
    it_behaves_like "it has form_fields"
    it_behaves_like "it has a custom json method"
  
  #Association Tests
    it_behaves_like "it has images"
    it_behaves_like "it has posts"
    it_behaves_like "it has tags"
    it_behaves_like "it has watchlists"
    it_behaves_like "it has self-relations"
    
    it_behaves_like "it has a primary relation", Album, AlbumOrganization
    it_behaves_like "it has a primary relation", Source, SourceOrganization
    it_behaves_like "it has a primary relation", Artist, ArtistOrganization
    
  #Validation Tests
    include_examples "is invalid without an attribute", :internal_name
    include_examples "is invalid without an attribute", :status
    include_examples "name/reference combinations"
        
    include_examples "is invalid without an attribute in a category", :status, Album::Status, "Album::Status"
    include_examples "is invalid without an attribute in a category", :db_status, Artist::DatabaseStatus, "Artist::DatabaseStatus"
    include_examples "is invalid without an attribute in a category", :activity, Organization::Activity, "Organization::Activity"
    include_examples "is invalid without an attribute in a category", :category, Organization::Categories, "Organization::Categories"

    include_examples "redirects to a new record when db_status is hidden", :organization, "something"

    include_examples "is valid with or without an attribute", :synonyms, "hi"
    include_examples "is valid with or without an attribute", :db_status, "Complete"
    include_examples "is valid with or without an attribute", :activity, Organization::Activity.sample
    include_examples "is valid with or without an attribute", :category, Organization::Categories.sample
    include_examples "is valid with or without an attribute", :info, "Hi this is info"
    include_examples "is valid with or without an attribute", :private_info, "Hi this is private info"
    include_examples "is valid with or without an attribute", :synopsis, "Hi this is a synopsis"
    include_examples "is valid with or without an attribute", :popularity, 55
    
          
  #Serialization Tests
    it_behaves_like "it has a partial date", :established
    it_behaves_like "it has a serialized attribute", :reference
    it_behaves_like "it has a serialized attribute", :namehash
    

  #Instance Method Tests
    
  #Class Method Tests    
    context "has a full update method" do
      include_examples "updates with keys and values"
      include_examples "updates the reference properly"
      include_examples "can upload an image"
      include_examples "updates namehash properly"
      include_examples "can update a primary relationship", Artist, ArtistOrganization
      include_examples "can update self-relations"
      include_examples "updates dates properly", "established"
      include_examples "updates with normal attributes"      
    end   
    
  describe "Scoping" do 
    it_behaves_like "filters by status", Album::Status
    it_behaves_like "filters by category", Organization::Categories
    it_behaves_like "filters by activity", Organization::Activity
    it_behaves_like "filters by tag"
    it_behaves_like "filters by watchlist"    
    it_behaves_like "filters by self relation categories"
  end
end


