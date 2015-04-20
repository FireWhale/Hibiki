require 'rails_helper'

describe Source do
  include_examples "global model tests" #Global Tests
  
  describe "Module Tests" do
    it_behaves_like "it has a language field", "name"
    it_behaves_like "it can be solr-searched"
    it_behaves_like "it can be autocompleted"
    it_behaves_like "it has pagination"
    it_behaves_like "it has form_fields"
  end
  
  #Association Tests
    it_behaves_like "it has images"
    it_behaves_like "it has posts"
    it_behaves_like "it has tags"
    it_behaves_like "it has watchlists"
    it_behaves_like "it has self-relations"

    it_behaves_like "it has a primary relation", Album, AlbumSource
    it_behaves_like "it has a primary relation", Organization, SourceOrganization
    it_behaves_like "it has a primary relation", Song, SongSource
    it_behaves_like "it has_many through", Season, SourceSeason, :with_source_season
      
  #Validation Tests
    include_examples "is invalid without an attribute", :name
    include_examples "is invalid without an attribute", :status
    include_examples "name/reference combinations"    
    
    include_examples "is invalid without an attribute in a category", :status, Album::Status, "Album::Status"
    include_examples "is invalid without an attribute in a category", :db_status, Artist::DatabaseStatus, "Artist::DatabaseStatus"
    include_examples "is invalid without an attribute in a category", :activity, Source::Activity, "Source::Activity"
    include_examples "is invalid without an attribute in a category", :category, Source::Categories, "Source::Categories"
    
    include_examples "redirects to a new record when db_status is hidden", "something"
    
    include_examples "is valid with or without an attribute", :altname, "hi"
    include_examples "is valid with or without an attribute", :db_status, "Complete"
    include_examples "is valid with or without an attribute", :activity, Source::Activity.sample
    include_examples "is valid with or without an attribute", :category, Source::Categories.sample
    include_examples "is valid with or without an attribute", :info, "this is sum info"
    include_examples "is valid with or without an attribute", :private_info, "this is sum private_info"
    include_examples "is valid with or without an attribute", :synopsis, "this is a short description!"
    include_examples "is valid with or without an attribute", :plot_summary, "this is a plot summary"
    include_examples "is valid with or without an attribute", :popularity, 3
        
    
  #Serialization Tests
    it_behaves_like "it has a partial date", :release_date
    it_behaves_like "it has a partial date", :end_date
    it_behaves_like "it has a serialized attribute", :reference
    it_behaves_like "it has a serialized attribute", :namehash
    
  #Instance Method Tests
        
  #Class Method Tests    
    context "has a full update method" do
      include_examples "updates with keys and values"
      include_examples "updates the reference properly"
      include_examples "can upload an image"
      include_examples "can update a primary relationship", Organization, SourceOrganization
      include_examples "can update self-relations"
      
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
      
      include_examples "updates dates properly", "release_date"
      include_examples "updates dates properly", "end_date"
      include_examples "updates namehash properly"
      include_examples "updates with normal attributes"
      
    end
    
  describe "Scoping" do 
    it_behaves_like "filters by status", Album::Status
    it_behaves_like "filters by category", Source::Categories
    it_behaves_like "filters by activity", Source::Activity
    it_behaves_like "filters by date range", "release_date"
    it_behaves_like "filters by tag"
    it_behaves_like "filters by watchlist"    
    it_behaves_like "filters by self relation categories"
  end
end


