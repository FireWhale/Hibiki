require 'rails_helper'

describe Artist do
  include_examples "global model tests" #Global Tests

  describe "Concern Tests" do
    include_examples "it has the association module"
    include_examples "it is a translated model"
    include_examples "it has images"
    include_examples "it has posts"
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
    include_examples "it has a primary relation", Album, ArtistAlbum
    include_examples "it has a primary relation", Organization, ArtistOrganization
    include_examples "it has a primary relation", Song, ArtistSong
  end

  describe "Validation Tests" do
    include_examples "is invalid without an attribute", :internal_name
    include_examples "is invalid without an attribute", :status

    include_examples "is invalid without an attribute in a category", :status, Album::Status, "Album::Status"
    include_examples "is invalid without an attribute in a category", :db_status, Artist::DatabaseStatus, "Artist::DatabaseStatus"
    include_examples "is invalid without an attribute in a category", :activity, Artist::Activity, "Artist::Activity"
    include_examples "is invalid without an attribute in a category", :category, Artist::Categories, "Artist::Categories"

    include_examples "is valid with or without an attribute", :synonyms, "hi"
    include_examples "is valid with or without an attribute", :db_status, "Complete"
    include_examples "is valid with or without an attribute", :activity, Artist::Activity.sample
    include_examples "is valid with or without an attribute", :category, Artist::Categories.sample
    include_examples "is valid with or without an attribute", :info, "this is sum info"
    include_examples "is valid with or without an attribute", :private_info, "this is sum private_info"
    include_examples "is valid with or without an attribute", :synopsis, "this is a short description!"
    include_examples "is valid with or without an attribute", :gender, "male I think"
    include_examples "is valid with or without an attribute", :blood_type, "b+!"
    include_examples "is valid with or without an attribute", :birth_place, "maybe okinawa?"
    include_examples "is valid with or without an attribute", :popularity, 3
  end

  describe "Attribute Tests" do
    it_behaves_like "it has a partial date", :birth_date
    it_behaves_like "it has a partial date", :debut_date
    it_behaves_like "it has a serialized attribute", :namehash
  end

  describe "Class Method Tests" do
    it "responds to get_bitmask" do
      expect(Artist).to respond_to(:get_bitmask)
    end

    it "returns a bitmask that is within the right number range" do
      number = Array(1..Artist::Credits.count).sample
      categories = Artist::Credits.sample(number)
      expect(Artist.get_bitmask(categories)).to be < 2**(Artist::Credits.count)
    end

    it "accepts a single credit as a string in get_bitmask" do
      expect(Artist.get_bitmask("Performer")).to eq(4)
    end

    it "returns the expected bitmask from a list of categories" do
      expect(Artist.get_bitmask(["Performer", "FeatArranger"])).to eq(36)
    end

    it "responds to get_credits" do
      expect(Artist).to respond_to(:get_credits)
    end

    it "returns a list of categories that matches the bitmask" do
      bitmask = 21
      expect(Artist.get_credits(bitmask)).to match_array(["Performer", "FeatComposer", "Composer"])
    end

    it "is reversible with get_bitmask and get_credits" do
      array = Artist::Credits.shuffle[0..4]
      expect(Artist.get_credits(Artist.get_bitmask(array))).to match_array(array)
    end

    it "is reversible with get_bitmask and get_credits 2" do
      bitmask = Array(1..(2**Artist::Credits.count - 1)).sample
      expect(Artist.get_bitmask(Artist.get_credits(bitmask))).to eq(bitmask)
    end
  end

  describe "Callbacks/Hooks" do
    describe "After Save: manage_organizations" do
      include_examples "manages a primary association", Organization, ArtistOrganization
    end
  end

  describe "Scoping" do
    it_behaves_like "filters by status", Album::Status
    it_behaves_like "filters by category", Artist::Categories
    it_behaves_like "filters by activity", Artist::Activity
  end
end


