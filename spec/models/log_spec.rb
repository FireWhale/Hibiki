require 'rails_helper'

describe Log do
  include_examples "global model tests" #Global Tests

  describe "Association Tests" do
    it_behaves_like "it is a polymorphically-linked class", Loglist, [Album, Event, Artist, Organization, Source, Song], "model"
  end

  describe "Validation Tests" do
    include_examples "is invalid without an attribute", :category

    include_examples "is invalid without an attribute in a category", :category, Log::Categories - ["Private Message", "Blog Post"], "Log::Categories"

    include_examples "is valid with or without an attribute", :content, "haha this is content!"

    it "is valid with multiple loglists" do
       expect(build(:log, :with_multiple_loglists)).to be_valid
    end
  end

  describe "Scoping" do
    it_behaves_like "filters by category", Log::Categories
  end

  describe "Instance Methods" do
    describe "models" do
      it "returns a list of loglist records" do
        log = create(:log)
        album = create(:album)
        artist = create(:artist)
        create(:loglist, model: album, log: log)
        create(:loglist, model: artist, log: log)
        expect(log.models).to match_array([album,artist])
      end
    end

    describe "add_to_content" do
      it "adds to the attribute" do
        log = create(:log, content: "hi")
        log.add_to_content("added")
        expect(log.reload.content).to eq("hiadded")
      end

      it "reloads the content before appending" do
        log = create(:log, content: "hi")
        logdup = Log.last
        logdup.add_to_content(" Add!")
        expect(log.content).to eq("hi")
        log.add_to_content(" new add!")
        expect(log.reload.content).to eq("hi Add! new add!")
      end
    end
  end

end

describe Loglist do
  include_examples "global model tests" #Global Tests

  it_behaves_like "it is a polymorphic join model", Log, [Album, Event, Artist, Organization, Source, Song], "model"

end
