require 'rails_helper'

describe Album do
  #Gutcheck Test
  it "has a valid factory" do
    instance = FactoryGirl.create(:album)
    expect(instance).to be_valid
  end
  
  #Validation Tests
    it "is invalid without a name" do
      FactoryGirl.build(:album, name: nil).should_not be_valid  
      FactoryGirl.build(:album, name: "").should_not be_valid  
    end
    
    it "is invalid without a status" do
      FactoryGirl.build(:album, status: nil).should_not be_valid
      FactoryGirl.build(:album, status: "").should_not be_valid
    end
    
    it "has a unique name, date, catalog number combination" do
      instance = FactoryGirl.create(:album)
      expect(FactoryGirl.build(:album)).not_to be_valid
    end
  
  #Serialization Tests
    it "returns an album's namehash as a hash" do
      instance = FactoryGirl.create(:album, namehash: {:hi => 'ho', 'ho' => 'hi'})
      expect(instance.reload.namehash).to eq({:hi => 'ho', 'ho' => 'hi'})
    end
    
    it "returns an album's reference as a hash" do
      instance = FactoryGirl.create(:album, reference: {:hi => 'ho', 'ho' => 'hi'})
      expect(instance.reload.reference).to eq({:hi => 'ho', 'ho' => 'hi'})
    end
    
  #Instance Method Tests
    it "returns the right format/value when querying an attribute" 
  
    it "creates proper associations with full_update"
    
    it "returns the right values for autocomplete" 
    it "returns the right day/week/year" 
    
    it "handles variable dates from day/week/year"
    it "handles collection methods" 
    it "returns the right collection type" do
      instance = FactoryGirl.create(:user, :with_albums)
      expect(instance).to be_valid
      expect(Album.first.collection?(User.first)).to eq("Collected")
    end
  #Association Tests
    
  
  #Class Method Tests    
    
    
    
  #Scope Tests
    
    
  #Other Tests?
    #Pagination?
    #Delete images method?
end


