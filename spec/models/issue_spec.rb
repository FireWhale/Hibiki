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
    include_examples "is invalid without an attribute", :issue, :name
    include_examples "is invalid without an attribute", :issue, :category
    include_examples "is invalid without an attribute", :issue, :visibility
    include_examples "is invalid without an attribute", :issue, :status
    
    include_examples "is invalid without an attribute in a category", :issue, :category, Issue::Categories, "Issue::Categories"
    include_examples "is invalid without an attribute in a category", :issue, :status, Issue::Statuses, "Issue::Statuses"
    
    include_examples "is valid with or without an attribute", :issue, :resolution, Issue::Resolutions.sample
    include_examples "is valid with or without an attribute", :issue, :priority, Issue::Priorities.sample
    include_examples "is valid with or without an attribute", :issue, :difficulty, Issue::Difficulties.sample
    include_examples "is valid with or without an attribute", :issue, :description, "this is a description"    
    include_examples "is valid with or without an attribute", :issue, :private_info, "this is private info"   

    it "is invalid without a visiblity in the list??"
    
  #Scope Tests
  context "Category Scope Tests" do
    before(:each) do
      @buglist = create_list(:issue, 5, category: "Bug Report")
      @featurelist = create_list(:issue, 4, category: "Feature Request")
      @codelist = create_list(:issue, 2, category: "Code Change")
    end
 
    it "returns bug reports when called" do
      expect(Issue.bug_reports).to eq(@buglist)
    end
    
    it "returns feature requests when called" do
      expect(Issue.feature_requests).to eq(@featurelist)
    end
        
    it "returns bug reports when called" do
      expect(Issue.code_changes).to eq(@codelist)
    end
  end
    
    
end


