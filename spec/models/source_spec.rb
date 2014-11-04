require 'rails_helper'

describe Source do
  #Gutcheck Test
    it "has a valid factory" do
      instance = create(:source)
      expect(instance).to be_valid
    end
  
  #Shared Examples
    it_behaves_like "it has images", :source, Source
    it_behaves_like "it has tags", :source, Source
    it_behaves_like "it has posts", :source, Source
    it_behaves_like "it has watchlists", :source, Source
    it_behaves_like "it can be searched", :source, Source
    it_behaves_like "it can be autocompleted", :source
    it_behaves_like "it has pagination", "source"
  
  #Association Tests - a lot of em ( ﾟдﾟ)
    it_behaves_like "it has self-relations", :source, "source", RelatedSources
    it_behaves_like "it has a primary relation", :source, "album", AlbumSource, :album_source
    it_behaves_like "it has a primary relation", :source, "organization", SourceOrganization, :source_organization
    it_behaves_like "it has a primary relation", :source, "song", SongSource, :song_source

    it_behaves_like "it has_many", :source, "season", "source_season", SourceSeason, :with_source_season
      
  #Validation Tests
    include_examples "is invalid without an attribute", :source, :name
    include_examples "is invalid without an attribute", :source, :status
    include_examples "name/reference combinations", :source
    
    include_examples "is invalid without an attribute in a category", :source, :status, Album::Status, "Album::Status"
    include_examples "is invalid without an attribute in a category", :source, :db_status, Artist::DatabaseStatus, "Artist::DatabaseStatus"
    include_examples "is invalid without an attribute in a category", :source, :activity, Source::Activity, "Source::Activity"
    include_examples "is invalid without an attribute in a category", :source, :category, Source::Categories, "Source::Categories"
    
    include_examples "redirects to a new record when db_status is hidden", :source, "something"
    
    include_examples "is valid with or without an attribute", :source, :altname, "hi"
    include_examples "is valid with or without an attribute", :source, :db_status, "Complete"
    include_examples "is valid with or without an attribute", :source, :activity, Source::Activity.sample
    include_examples "is valid with or without an attribute", :source, :category, Source::Categories.sample
    include_examples "is valid with or without an attribute", :source, :info, "this is sum info"
    include_examples "is valid with or without an attribute", :source, :private_info, "this is sum private_info"
    include_examples "is valid with or without an attribute", :source, :synopsis, "this is a short description!"
    include_examples "is valid with or without an attribute", :source, :plot_summary, "this is a plot summary"
    include_examples "is valid with or without an attribute", :source, :popularity, 3
        
    it_behaves_like "it has a partial date", :source, :release_date
    it_behaves_like "it has a partial date", :source, :end_date
    
  #Serialization Tests
    it_behaves_like "it has a serialized attribute", :source, :reference
    it_behaves_like "it has a serialized attribute", :source, :namehash
    
  #Instance Method Tests
        
  #Class Method Tests    
    context "hass a full update method" do
      include_examples "updates with keys and values", :source
      include_examples "updates the reference properly", :source
      include_examples "can upload an image", :source
      include_examples "can update a primary relationship", :source, :organization, SourceOrganization, "source_organization"
      include_examples "can update self-relations", :organization
      it "adds seasons"
      include_examples "updates dates properly", :source, "release_date"
      include_examples "updates dates properly", :source, "end_date"
      include_examples "updates with normal attributes", :source
      
    end
        
  #Scope Tests
    it "reports released records"
        
end


