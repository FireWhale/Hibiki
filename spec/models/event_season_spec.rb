require 'rails_helper'

describe Event do
  include_examples "global model tests" #Global Tests
  
  describe "Concern Tests" do
    include_examples "it has a custom json method"
    
    it_behaves_like "it has form_fields"
  end
  
  describe "Association Tests" do
    describe "Album Events" do
      include_examples "it has_many through", Album, AlbumEvent, :with_album_event
    end
  end
  
  describe "Validation Tests" do
    it_behaves_like "is valid with or without an attribute", :name, "name"
    it_behaves_like "is valid with or without an attribute", :shorthand, "name"
    it_behaves_like "is valid with or without an attribute", :start_date, Date.new(2132,1,4)
    it_behaves_like "is valid with or without an attribute", :end_date, Date.new(2032,3,12)
        
    it "is invalid if it does not have a name or shorthand" do
      expect(build(:event, name: nil, shorthand: nil)).to_not be_valid
    end
    
    it "is valid with the same start and end dates" do
      create(:event, start_date: Date.new(2012, 1, 1), end_date: Date.new(2013,1,1))
      expect(build(:event, start_date: Date.new(2012, 1, 1), end_date: Date.new(2013,1,1))).to be_valid
    end
  end

  #Serialization Tests
    it_behaves_like "it has a serialized attribute", :reference
     
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
      include_examples "updates with keys and values"
      include_examples "updates the reference properly"
      include_examples "updates with normal attributes"
    end
end

describe Season do
  include_examples "global model tests" #Global Tests
  
  describe "Concern Tests" do
    include_examples "it has images"
    include_examples "it has a custom json method"
    
    it_behaves_like "it has form_fields"
  end
  
  #Association Test
    it_behaves_like "it has_many through", Source, SourceSeason, :with_source_season
  
  #Validation Tests  
    include_examples "is invalid without an attribute", :name
    include_examples "is invalid without an attribute", :start_date
    include_examples "is invalid without an attribute", :end_date

    it "is valid with overlapping dates" do
      create(:season, start_date: Date.new(2012, 1, 1), end_date: Date.new(2013,1,1))
      expect(build(:season, start_date: Date.new(2012, 1, 1), end_date: Date.new(2013,1,1))).to be_valid
    end

  context "has a full update method" do
    include_examples "updates with keys and values"
    include_examples "can upload an image"
    include_examples "can update a primary relationship", Source, SourceSeason
    include_examples "updates with normal attributes"
  end
    
end

describe AlbumEvent do
  include_examples "global model tests" #Global Tests
    
  #Association Test
    it_behaves_like "a join table", Album, Event
    
end

describe SourceSeason do
  include_examples "global model tests" #Global Tests
    
  #Association Test
    it_behaves_like "a join table", Source, Season
  
  #Validation Tests  
    include_examples "is invalid without an attribute", :category
    include_examples "is invalid without an attribute in a category", :category, SourceSeason::Categories, "SourceSeason::Categories"

  
end


