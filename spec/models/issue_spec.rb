require 'rails_helper'

describe Issue do
  #Gutcheck Test
  it "has a valid factory" do
    expect(create(:issue)).to be_valid
  end
    
  #Association Tests
    it "should have many IssueUsers" do
      expect(Issue.reflect_on_association(:issue_users).macro).to eq(:has_many)
    end
    
    it "can have an IssueUser association" do
      expect(create(:issue, :with_comments).issue_users.first).to be_a IssueUser
    end 
    
    it "destroys IssueUsers when destroyed" do
      issue = create(:issue, :with_comments)
      expect{issue.destroy}.to change(IssueUser, :count).by(-1)
    end
    
    it "does not destroy Users when destroyed" do
      #creating an issue with comments will create a user too.
      issue = create(:issue, :with_comments)
      #Test the expect
      expect{issue.destroy}.to change(User, :count).by(0)
    end
    
  #Validation Tests
    it "is valid with a name, category, visiblity, and status" do
      expect(create(:issue)).to be_valid
    end
    
    it "is invalid without a name" do
      expect(build(:issue, name: nil)).not_to be_valid  
      expect(build(:issue, name: "")).to_not be_valid  
    end
    
    it "is invalid without a category" do
      expect(build(:issue, category: nil)).not_to be_valid  
      expect(build(:issue, category: "")).to_not be_valid  
    end
    
    it "is invalid without a visibility" do
      expect(build(:issue, visibility: nil)).not_to be_valid  
      expect(build(:issue, visibility: "")).to_not be_valid  
    end
    #Consider these?
    it "is invalid without a visiblity in the list??"
    
    it "is invalid without a status in the list??"
    
    it "is invalid without a category defined in Issue??"
    
    it "is invalid without a status" do
      expect(build(:issue, status: nil)).not_to be_valid  
      expect(build(:issue, status: "")).to_not be_valid  
    end
    
    #It's okay to not have resolution, priority, description, or difficulty validated
        
  #Instance Method Tests

      
  #Class Method Tests        
        
  #Scope Tests
        
  #Other Tests?
    #Pagination?
    #Delete images method?
end


