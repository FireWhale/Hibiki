require 'rails_helper'

describe User do
  #Gutcheck Test
  it "has a valid factory" do
    instance = FactoryGirl.create(:album)
    expect(instance).to be_valid
  end
  
  #Association tests
    it "has many collections"
    
    it "has many watchelists"
    
    it "has many Ratings"
    
    it "has many IssueUsers"
    
    it "has many Images"
    
    it "has many posts as user"
    
    it "has many posts as recipient"
  
  #Validation Tests
  
  #Serialization Tests
    
  #Instance Method Tests
  
  #Class Method Tests    
    
    
    
  #Scope Tests
    
    
  #Other Tests?
    #Pagination?
    #Delete images method?
end


