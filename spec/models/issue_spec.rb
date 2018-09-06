require 'rails_helper'

describe Issue do
  include_examples "global model tests" #Global Tests

  describe "Concern Tests" do
    include_examples "it has a custom json method"
    include_examples "it has custom pagination"

    include_examples "it has form_fields"
  end


  describe "Validation Tests" do
    include_examples "is invalid without an attribute", :name
    include_examples "is invalid without an attribute", :category
    include_examples "is invalid without an attribute", :visibility
    include_examples "is invalid without an attribute", :status

    include_examples "is invalid without an attribute in a category", :category, Issue::Categories, "Issue::Categories"
    include_examples "is invalid without an attribute in a category", :status, Issue::Status, "Issue::Statuses"
    include_examples "is invalid without an attribute in a category", :visibility, Rails.application.secrets.roles, "Rails.application.secrets.roles"

    include_examples "is valid with or without an attribute", :resolution, Issue::Resolutions.sample
    include_examples "is valid with or without an attribute", :priority, Issue::Priorities.sample
    include_examples "is valid with or without an attribute", :difficulty, Issue::Difficulties.sample
    include_examples "is valid with or without an attribute", :description, "this is a description"
    include_examples "is valid with or without an attribute", :private_info, "this is private info"
  end

  context "Scope Tests" do
    it_behaves_like "filters by category", Issue::Categories
    it_behaves_like "filters by status", Issue::Status
    it_behaves_like "filters by role"

    describe "behaves like filters by priority" do
      include_examples "filters by a column", "priority", Issue::Priorities
    end

    describe "behaves like filters by difficulty" do
      include_examples "filters by a column", "difficulty", Issue::Difficulties
    end
  end


end


