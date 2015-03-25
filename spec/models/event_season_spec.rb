require 'rails_helper'

describe Event do
  #Gutcheck Test
    it "has a valid factory" do
      instance = create(:event)
      expect(instance).to be_valid
    end
  
  #Association Test
    it_behaves_like "it has_many", :event, "album", "album_event", AlbumEvent, :with_album_event
  
  #Validation Tests
    it_behaves_like "is valid with or without an attribute", :event, :name, "name"
    it_behaves_like "is valid with or without an attribute", :event, :shorthand, "name"
    it_behaves_like "is valid with or without an attribute", :event, :start_date, Date.new(2132,1,4)
    it_behaves_like "is valid with or without an attribute", :event, :end_date, Date.new(2032,3,12)
        
    it "is invalid if it does not have a name or shorthand" do
      expect(build(:event, name: nil, shorthand: nil)).to_not be_valid
    end
    
    it "is valid with overlapping dates" do
      create(:event, start_date: Date.new(2012, 1, 1), end_date: Date.new(2013,1,1))
      expect(build(:event, start_date: Date.new(2012, 1, 1), end_date: Date.new(2013,1,1))).to be_valid
    end

  #Serialization Tests
    it_behaves_like "it has a serialized attribute", :event, :reference
     
  #Instance Method Tests
    it "returns the right name with name_helper" do
      expect(create(:event, name: "hi", shorthand: "this one!").name_helper("shorthand", "name")).to eq("this one!")
    end
    
    it "returns nil if no name_helper name matches" do
      expect(create(:event, name: "hi", shorthand: "this one!").name_helper("nope", "nada")).to eq(nil)
    end
    
    it "skips non-eligable names with name_helper" do
      expect(create(:event, name: "hi", shorthand: "this one!").name_helper("hi", "shorthand", "name")).to eq("this one!")
    end
    
    it "returns the date range" 
      #instance = create(:event, start_date: Date.new(2014, 1, 1), end_date: Date.new(2014, 1, 1))

    #Full Update
      context "has a full update method" do
        include_examples "updates with keys and values", :event
        include_examples "updates the reference properly", :event
        include_examples "updates with normal attributes", :event
      end
end

describe Season do
  #Gutcheck Test
    it "has a valid factory" do
      instance = create(:season)
      expect(instance).to be_valid
    end
  
  #Association Test
    it_behaves_like "it has_many", :season, "source", "source_season", SourceSeason, :with_source_season
  
  #Validation Tests  
    include_examples "is invalid without an attribute", :season, :name
    include_examples "is invalid without an attribute", :season, :start_date
    include_examples "is invalid without an attribute", :season, :end_date

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
    it_behaves_like "a join table", :album_event, "album", "event", AlbumEvent
    
end

describe SourceSeason do
  #Gutcheck Test
    it "has a valid factory" do
      instance = create(:source_season)
      expect(instance).to be_valid
    end
    
  #Association Test
    it_behaves_like "a join table", :source_season, "source", "season", SourceSeason
  
  #Validation Tests  
    include_examples "is invalid without an attribute", :source_season, :category
    include_examples "is invalid without an attribute in a category", :source_season, :category, SourceSeason::Categories, "SourceSeason::Categories"

  
end


