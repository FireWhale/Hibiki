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
    context "has a full update method" do
      include_examples "updates with keys and values", :source
      include_examples "updates the reference properly", :source
      include_examples "can upload an image", :source
      include_examples "can update a primary relationship", :source, :organization, SourceOrganization, "source_organization"
      include_examples "can update self-relations", :organization
      context "it full updates seasons" do 
        it "adds an season" do
          source = create(:source)
          attributes = attributes_for(:source)
          season = create(:season, name: "shorty")
          attributes.merge!(:new_season_names => ["shorty"], :new_season_categories => ["Airing"])
          expect{source.full_update_attributes(attributes)}.to change(SourceSeason, :count).by(1)
          expect(source.seasons.first).to eq(season)
        end
        
        it "does not create seasons that do not exist" do
          source = create(:source)
          attributes = attributes_for(:source)
          attributes.merge!(:new_season_names => ["shorty"], :new_season_categories => ["Airing"])
          expect{source.full_update_attributes(attributes)}.to change(Season, :count).by(0)
        end
        
        it "deletes an sourceseason" do
          source = create(:source)
          season = create(:season)
          source_season = create(:source_season, season: season, source: source)
          attributes = attributes_for(:source)
          attributes.merge!(:remove_seasons => [season.id.to_s])
          expect{source.full_update_attributes(attributes)}.to change(SourceSeason, :count).by(-1)
        end
        
        it "does not delete the season" do
          source = create(:source)
          season = create(:season)
          source_season = create(:source_season, season: season, source: source)
          attributes = attributes_for(:source)
          attributes.merge!(:remove_seasons => [season.id.to_s])
          expect{source.full_update_attributes(attributes)}.to change(Season, :count).by(0)
        end
        
        it "does not delete an sourceseason that does not exist" do
          source = create(:source)
          season = create(:season)
          source_season = create(:source_season, source: source)
          attributes = attributes_for(:source)
          attributes.merge!(:remove_seasons => [season.id.to_s])
          expect{source.full_update_attributes(attributes)}.to change(SourceSeason, :count).by(0)
        end
        
        it "adds multiple seasons" do
          source = create(:source)
          attributes = attributes_for(:source)
          season = create(:season, name: "shorty")
          season2 = create(:season, name: "tally")
          attributes.merge!(:new_season_names => ["shorty", "tally"], :new_season_categories => ["Airing", "Movie"])
          expect{source.full_update_attributes(attributes)}.to change(SourceSeason, :count).by(2)
          expect(source.seasons).to match_array([season, season2])          
        end
        
        it "adds multiple seasons that exist and not seasons that do not" do
          source = create(:source)
          attributes = attributes_for(:source)
          season = create(:season, name: "shorty")
          season2 = create(:season, name: "tally")
          attributes.merge!(:new_season_names => ["shorty", "tally", "holly"], :new_season_categories => ["Airing", "Movie", "Short"])
          expect{source.full_update_attributes(attributes)}.to change(SourceSeason, :count).by(2)
          expect(source.seasons.count).to eq(2)   
          expect(Season.find_by_name("holly")).to be nil           
        end
        
        it "removes multiple seasons" do
          source = create(:source)
          season = create(:season)
          season2 = create(:season)
          source_season = create(:source_season, season: season, source: source)
          source_season2 = create(:source_season, season: season2, source: source)
          attributes = attributes_for(:source)
          attributes.merge!(:remove_seasons => [season.id.to_s, season2.id.to_s])
          expect{source.full_update_attributes(attributes)}.to change(SourceSeason, :count).by(-2)
        end
      end
      include_examples "updates dates properly", :source, "release_date"
      include_examples "updates dates properly", :source, "end_date"
      include_examples "updates with normal attributes", :source
      
    end
        
  #Scope Tests
    it_behaves_like "it reports released records", :source
        
end


