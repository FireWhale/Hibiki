require 'rails_helper'

describe Issue do
  include_examples "global model tests" #Global Tests
    
  describe "Module Tests" do
    it_behaves_like "it has form_fields"
  end
  
  #Association Tests
    it_behaves_like "it has_many through", User, IssueUser, :with_issue_user

  #Validation Tests
    include_examples "is invalid without an attribute", :name
    include_examples "is invalid without an attribute", :category
    include_examples "is invalid without an attribute", :visibility
    include_examples "is invalid without an attribute", :status
    
    include_examples "is invalid without an attribute in a category", :category, Issue::Categories, "Issue::Categories"
    include_examples "is invalid without an attribute in a category", :status, Issue::Status, "Issue::Statuses"
    include_examples "is invalid without an attribute in a category", :visibility, Ability::Abilities, "Ability::Abilities"
    
    include_examples "is valid with or without an attribute", :resolution, Issue::Resolutions.sample
    include_examples "is valid with or without an attribute", :priority, Issue::Priorities.sample
    include_examples "is valid with or without an attribute", :difficulty, Issue::Difficulties.sample
    include_examples "is valid with or without an attribute", :description, "this is a description"    
    include_examples "is valid with or without an attribute", :private_info, "this is private info"   

  #Scope Tests
  context "Scope Tests" do
    it_behaves_like "filters by category", Issue::Categories
    it_behaves_like "filters by status", Issue::Status
    it_behaves_like "filters by security"
    describe "behaves like filters by priority" do
      include_examples "filters by a column", "priority", Issue::Priorities
    end
    describe "behaves like filters by difficulty" do
      include_examples "filters by a column", "difficulty", Issue::Difficulties
    end
  end
    
    
end


