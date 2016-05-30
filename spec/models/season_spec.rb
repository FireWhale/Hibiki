require 'rails_helper'

describe Season do
  include_examples "global model tests" #Global Tests

  describe "Concern Tests" do
    include_examples "it has the association module"
    include_examples "it has images"
    include_examples "it has a custom json method"

    include_examples "it has form_fields"
  end

  describe "Association Tests" do
    it_behaves_like "it has_many through", Source, SourceSeason, :with_source_season
  end

  describe "Validation Tests" do
    include_examples "is invalid without an attribute", :name
    include_examples "is invalid without an attribute", :start_date
    include_examples "is invalid without an attribute", :end_date

    it "is valid with overlapping dates" do
      create(:season, start_date: Date.new(2012, 1, 1), end_date: Date.new(2013,1,1))
      expect(build(:season, start_date: Date.new(2012, 1, 1), end_date: Date.new(2013,1,1))).to be_valid
    end
  end

  describe "Callbacks/Hooks" do
    describe "After Save: manage_sources" do
      include_examples "manages a primary association", Source, SourceSeason
    end
  end

end

describe SourceSeason do
  include_examples "global model tests" #Global Tests

  #Association Test
    it_behaves_like "a join table", Source, Season

  #Validation Tests
    include_examples "is invalid without an attribute", :category
    include_examples "is invalid without an attribute in a category", :category, SourceSeason::Categories, "SourceSeason::Categories"

end