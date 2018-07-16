require 'rails_helper'

describe Organization do
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
    include_examples "it has partial dates"

    include_examples "it has form_fields"
  end

  describe "Association Tests" do
    it_behaves_like "it has a primary relation", Album, AlbumOrganization
    it_behaves_like "it has a primary relation", Source, SourceOrganization
    it_behaves_like "it has a primary relation", Artist, ArtistOrganization
  end

  describe "Validation Tests" do
    include_examples "is invalid without an attribute", :internal_name
    include_examples "is invalid without an attribute", :status

    include_examples "is invalid without an attribute in a category", :status, Album::Status, "Album::Status"
    include_examples "is invalid without an attribute in a category", :db_status, Artist::DatabaseStatus, "Artist::DatabaseStatus"
    include_examples "is invalid without an attribute in a category", :activity, Organization::Activity, "Organization::Activity"
    include_examples "is invalid without an attribute in a category", :category, Organization::Categories, "Organization::Categories"

    include_examples "is valid with or without an attribute", :synonyms, "hi"
    include_examples "is valid with or without an attribute", :db_status, "Complete"
    include_examples "is valid with or without an attribute", :activity, Organization::Activity.sample
    include_examples "is valid with or without an attribute", :category, Organization::Categories.sample
    include_examples "is valid with or without an attribute", :info, "Hi this is info"
    include_examples "is valid with or without an attribute", :private_info, "Hi this is private info"
    include_examples "is valid with or without an attribute", :synopsis, "Hi this is a synopsis"
    include_examples "is valid with or without an attribute", :popularity, 55
  end

  describe "Attribute Tests" do
    it_behaves_like "it has a partial date", :established
    it_behaves_like "it has a serialized attribute", :namehash
  end

  describe "Callbacks/Hooks" do
    describe "After Save: manage_artists" do
      include_examples "manages a primary association", Artist, ArtistOrganization
    end
  end

  describe "Scoping" do
    it_behaves_like "filters by status", Album::Status
    it_behaves_like "filters by category", Organization::Categories
    it_behaves_like "filters by activity", Organization::Activity
  end
end


