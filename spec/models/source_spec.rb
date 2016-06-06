require 'rails_helper'

describe Source do
  include_examples "global model tests" #Global Tests

  describe "Concern Tests" do
    include_examples "it has the association module"
    include_examples "it is a translated model"
    include_examples "it has images"
    include_examples "it has posts"
    include_examples "it has logs"
    include_examples "it has tags"
    include_examples "it has watchlists"
    include_examples "it has self-relations"
    include_examples "it can be solr-searched"
    include_examples "it has a custom json method"
    include_examples "it has references"
    include_examples "it has custom pagination"

    include_examples "it has form_fields"
  end

  describe "Association Tests" do
    it_behaves_like "it has a primary relation", Album, AlbumSource
    it_behaves_like "it has a primary relation", Organization, SourceOrganization
    it_behaves_like "it has a primary relation", Song, SongSource
    it_behaves_like "it has_many through", Season, SourceSeason, :with_source_season
  end

  describe "Validation Tests" do
    include_examples "is invalid without an attribute", :internal_name
    include_examples "is invalid without an attribute", :status

    include_examples "is invalid without an attribute in a category", :status, Album::Status, "Album::Status"
    include_examples "is invalid without an attribute in a category", :db_status, Artist::DatabaseStatus, "Artist::DatabaseStatus"
    include_examples "is invalid without an attribute in a category", :activity, Source::Activity, "Source::Activity"
    include_examples "is invalid without an attribute in a category", :category, Source::Categories, "Source::Categories"

    include_examples "is valid with or without an attribute", :synonyms, "hi"
    include_examples "is valid with or without an attribute", :db_status, "Complete"
    include_examples "is valid with or without an attribute", :activity, Source::Activity.sample
    include_examples "is valid with or without an attribute", :category, Source::Categories.sample
    include_examples "is valid with or without an attribute", :info, "this is sum info"
    include_examples "is valid with or without an attribute", :private_info, "this is sum private_info"
    include_examples "is valid with or without an attribute", :synopsis, "this is a short description!"
    include_examples "is valid with or without an attribute", :plot_summary, "this is a plot summary"
    include_examples "is valid with or without an attribute", :popularity, 3
  end

  describe "Callbacks/Hooks" do
    describe "After Save: manage_organizations" do
      include_examples "manages a primary association", Organization, SourceOrganization
    end
  end

  describe "Serialization Tests" do
    it_behaves_like "it has a partial date", :release_date
    it_behaves_like "it has a partial date", :end_date
    it_behaves_like "it has a serialized attribute", :namehash
  end

  describe "Scoping" do
    it_behaves_like "filters by status", Album::Status
    it_behaves_like "filters by category", Source::Categories
    it_behaves_like "filters by activity", Source::Activity
    it_behaves_like "filters by date range", "release_date"
  end
end


