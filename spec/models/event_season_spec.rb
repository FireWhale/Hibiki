require 'rails_helper'

describe Event do
  #Gutcheck Test
    it "has a valid factory" do
      instance = create(:event)
      expect(instance).to be_valid
    end
  
  #Association Test
    it "has many AlbumEvents" do
      expect(create(:event, :with_album_event).album_events.first).to be_a AlbumEvent
      expect(Event.reflect_on_association(:album_events).macro).to eq(:has_many)
    end
    
    it "has many albums" do
      expect(Event.reflect_on_association(:albums).macro).to eq(:has_many)
    end

    it "destroys album_events when destroyed" do
      event = create(:event, :with_album_event)
      expect{event.destroy}.to change(AlbumEvent, :count).by(-1)
    end    
    
    it "does not destroy albums when destroyed" do
      event = create(:event, :with_album_event)
      expect{event.destroy}.to change(Album, :count).by(0)
    end
  
  #Validation Tests
    it "is valid without a name" do
      expect(build(:event, name: nil)).to be_valid  
      expect(build(:event, name: "")).to be_valid  
    end
    
    it "is valid without a shorthand" do
      expect(build(:event, name: nil)).to be_valid  
      expect(build(:event, name: "")).to be_valid  
    end
    
    it "is valid without a start date" do
      expect(build(:event, start_date: nil)).to be_valid
    end
    
    it "is valid without an end date" do
      expect(build(:event, end_date: nil)).to be_valid
    end
    
    it "is invalid if it does not have a name or shorthand" do
      expect(build(:event, name: nil, shorthand: nil)).to_not be_valid
    end
    
    it "is valid with overlapping dates" do
      create(:event, start_date: Date.new(2012, 1, 1), end_date: Date.new(2013,1,1))
      expect(build(:event, start_date: Date.new(2012, 1, 1), end_date: Date.new(2013,1,1))).to be_valid
    end
     
  #Instance Method Tests
    it "returns the reference as a hash" do
      expect(create(:event).reference).to be_a Hash
    end  
      
    it "updates reference appropriately" do
      instance = create(:event, reference: {:hi => 'ho', 'ho' => 'hi'})
      expect(instance.reload.reference).to eq({:hi => 'ho', 'ho' => 'hi'})      
    end

    it "returns the name if shorthand is nil" do
      expect(create(:event, name: "hi", shorthand: nil).shorthand_or_name).to eq("hi")
    end
    
    it "returns the shorthand if name is nil" do
      expect(create(:event, name: nil, shorthand: "ahahah").name_or_shorthand).to eq("ahahah")      
    end
    
    it "returns the date range" 
      #instance = create(:event, start_date: Date.new(2014, 1, 1), end_date: Date.new(2014, 1, 1))

    it "full updates with keys and values"
    
    it "full_update_attributes with reference values"      
end

describe Season do
  #Gutcheck Test
    it "has a valid factory" do
      instance = create(:season)
      expect(instance).to be_valid
    end
  
  #Association Test
    it "has many SourceSeasons" do
      expect(create(:season, :with_source_season).source_seasons.first).to be_a SourceSeason
      expect(Season.reflect_on_association(:source_seasons).macro).to eq(:has_many)
    end
    
    it "has many sources" do
      expect(Season.reflect_on_association(:sources).macro).to eq(:has_many)      
    end
    
    it "destroys source_seasons when destroyed" do
      season = create(:season, :with_source_season)
      expect{season.destroy}.to change(SourceSeason, :count).by(-1)
    end
    
    it "does not destory sources when destroyed" do
      season = create(:season, :with_source_season)
      expect{season.destroy}.to change(Source, :count).by(0)
    end
  
  #Validation Tests
    it "is valid with a name, start date, and end date" do
      expect(create(:season)).to be_valid
    end
  
    it "is invalid without a name" do
      expect(build(:season, name: nil)).to_not be_valid  
      expect(build(:season, name: "")).to_not be_valid  
    end
    
    it "is invalid without a start date" do
      expect(build(:season, start_date: nil)).to_not be_valid
    end
    
    it "is invalid without an end date" do
      expect(build(:season, end_date: nil)).to_not be_valid
    end
    
    it "is valid with overlapping dates" do
      create(:season, start_date: Date.new(2012, 1, 1), end_date: Date.new(2013,1,1))
      expect(build(:season, start_date: Date.new(2012, 1, 1), end_date: Date.new(2013,1,1))).to be_valid
    end
    
end

describe AlbumEvent do
  #Gutcheck Test
    it "has a valid factory" do
      expect(create(:album_event)).to be_valid
    end
    
  #Association Test
    it "belongs to albums" do
      expect(create(:album_event).album).to be_a Album
      expect(AlbumEvent.reflect_on_association(:album).macro).to eq(:belongs_to)
    end    
    
    it "belongs to events" do
      expect(create(:album_event).event).to be_a Event
      expect(AlbumEvent.reflect_on_association(:event).macro).to eq(:belongs_to)
    end
  
  #Validation Tests  
    it "is valid with an album, event, and category" do
      expect(build(:album_event)).to be_valid
    end
    
    it "is invalid without an album" do
      expect(build(:album_event, album: nil)).to_not be_valid
    end
    
    it "is invalid without a real album" do
      expect(build(:album_event, album_id: 999999999)).to_not be_valid
    end
    
    it "is invalid without an event" do
      expect(build(:album_event, event: nil)).to_not be_valid      
    end
    
    it "is invalid without a real event" do
      expect(build(:album_event, event_id: 999999999)).to_not be_valid      
    end
    
    it "is valid without a category" do
      expect(build(:album_event, category: nil)).to be_valid
      expect(build(:album_event, category: "")).to be_valid      
    end
        
    it "should not have duplicate album/event combinations" do
      @album = create(:album)
      @event = create(:event)
      expect(create(:album_event, album: @album, event: @event)).to be_valid
      expect(build(:album_event, album: @album, event: @event)).to_not be_valid      
    end
    
  
end

describe SourceSeason do
  #Gutcheck Test
    it "has a valid factory" do
      instance = create(:source_season)
      expect(instance).to be_valid
    end
    
  #Association Test
    it "belongs to sources" do
      expect(create(:source_season).source).to be_a Source
      expect(SourceSeason.reflect_on_association(:source).macro).to eq(:belongs_to)
    end    
    
    it "belongs to seasons" do
      expect(create(:source_season).season).to be_a Season
      expect(SourceSeason.reflect_on_association(:season).macro).to eq(:belongs_to)
    end
  
  #Validation Tests  
    it "is valid with an source, season, and category" do
      expect(build(:source_season)).to be_valid
    end
    
    it "is invalid without an source" do
      expect(build(:source_season, source: nil)).to_not be_valid
    end
    
    it "is invalid without a real source" do
      expect(build(:source_season, source_id: 9999999999)).to_not be_valid
    end
    
    it "is invalid without an season" do
      expect(build(:source_season, season: nil)).to_not be_valid
    end
    
    it "is invalid without a real season" do
      expect(build(:source_season, season_id: 9999999999)).to_not be_valid
    end
    
    it "is invalid without a category" do
      expect(build(:source_season, category: nil)).to_not be_valid
      expect(build(:source_season, category: "")).to_not be_valid      
    end
    
    it "is invalid with a category not in the category list" do
      expect(build(:source_season, category: "ohhohohoho")).to_not be_valid   
    end
    
    it "should not have duplicate source/season combinations" do
      @source = create(:source)
      @season = create(:season)
      expect(create(:source_season, source: @source, season: @season)).to be_valid
      expect(build(:source_season, source: @source, season: @season)).to_not be_valid
    end
  
end


