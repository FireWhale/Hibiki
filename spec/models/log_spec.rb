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

  describe "Class Methods" do
    describe "find_last(category)" do
      it "returns nothing without a valid category" do
        expect(Log.find_last("not existing")).to be_nil
      end

      it "returns a record with a valid category" do
        log = create(:log, category: "Scrape")
        expect(Log.find_last("Scrape")).to eq(log)
      end
    end

    describe "find_or_create_by_length" do
      it "doesn't create a log if the length is okay" do
        log = create(:log, category: "Rescrape")
        expect(Log.find_or_create_by_length("Rescrape",1000)).to eq(log)
      end

      it "creates a log if the length is too long" do
        log = create(:log, category: "Rescrape", content: "long")
        expect(Log.find_or_create_by_length("Rescrape",1)).to_not eq(log)
      end

      it "creates a log if there is no previous log" do
        expect(Log.find_or_create_by_length("Rescrape",1000)).to be_a(Log)
      end

    end
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
        log.add_to_content('warn',"added")
        expect(log.reload.content).to eq("hi[WARN]added\n")
      end

      it "reloads the content before appending" do
        log = create(:log, content: "hi")
        logdup = Log.last
        logdup.add_to_content('info'," Add!")
        expect(log.content).to eq("hi")
        log.add_to_content('error'," new add!")
        expect(log.reload.content).to eq("hi[INFO] Add!\n[ERROR] new add!\n")
      end
    end

    describe "previous_log" do
      it "returns nil if there is no previous log" do
        log = create(:log)
        expect(log.previous_log).to be_nil
      end

      it "returns the previous log of the same category"do
        log1 = create(:log, category: "Scrape")
        log2 = create(:log, category: "Rescrape")
        log3 = create(:log, category: "Scrape")
        expect(log3.previous_log).to eq(log1)
        expect(log3.previous_log).to_not eq(log2)
      end

    end

    describe "next_log" do
      it "returns nil if there is no next log" do
        log = create(:log)
        expect(log.next_log).to be_nil
      end

      it "returns the previous log of the same category" do
        log1 = create(:log, category: "Scrape")
        log2 = create(:log, category: "Rescrape")
        log3 = create(:log, category: "Scrape")
        expect(log1.next_log).to eq(log3)
        expect(log1.next_log).to_not eq(log2)
      end

    end
  end
end

describe Loglist do
  include_examples "global model tests" #Global Tests

  it_behaves_like "it is a polymorphic join model", Log, [Album, Event, Artist, Organization, Source, Song], "model"

end
