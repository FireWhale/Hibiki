require 'rails_helper'

describe Tag do
  include_examples "global model tests" #Global Tests

  describe "Concern Tests" do
    include_examples "it is a translated model"
    include_examples "it has a custom json method"

    include_examples "it has form_fields"
  end

  describe "Callbacks/Hooks" do
    describe "Before Validation: convert_models_to_bitmask" do
      it "has tag_models as an attr_accessor" do
        tag = build(:tag)
        expect(tag).to respond_to("tag_models")
        expect(tag).to respond_to("tag_models=")
      end

      it "converts an array of models to a bitmask" do
        tag = build(:tag, tag_models: ["Album", "Artist"], model_bitmask: 1)
        tag.save
        expect(tag.reload.model_bitmask).to eq(3)
      end
    end
  end

  describe "Association Tests" do
    it_behaves_like "it is a polymorphically-linked class", Taglist, [Album, Artist, Organization, Source, Song, Post], "subject"
  end

  describe "Validation Tests" do
    include_examples "is invalid without an attribute", :internal_name
    include_examples "is invalid without an attribute", :classification
    include_examples "is invalid without an attribute", :model_bitmask
    include_examples "is invalid without an attribute", :visibility

    include_examples "is invalid without an attribute in a category", :visibility, Rails.application.secrets.roles, "Rails.application.secrets.roles"

    include_examples "is valid with or without an attribute", :info, "This is info!"

    it "is valid with multiple taglists" do
       expect(build(:tag, :with_multiple_taglists)).to be_valid
    end

    it "is invalid without a model_bitmask that is small enough" do
      expect(build(:tag, model_bitmask: 99999999)).to_not be_valid
    end

    it "is invalid with duplicate name/model_bitmask" do
      expect(create(:tag, internal_name: "hi", model_bitmask: 8)).to be_valid
      expect(build(:tag, internal_name: "hi", model_bitmask: 8)).to_not be_valid
    end

    it "is valid with duplicate names if bitmask is different" do
      expect(create(:tag, name: "hi", model_bitmask: 8)).to be_valid
      expect(build(:tag, name: "hi", model_bitmask: 14)).to be_valid
    end

    it "is valid with duplicate bitmasks if name is different" do
      expect(create(:tag, name: "hio", model_bitmask: 14)).to be_valid
      expect(build(:tag, name: "hi", model_bitmask: 14)).to be_valid
    end
  end

  describe "Instance Methods" do
    describe "models" do
      it "returns an array of models" do
        expect(build(:tag, model_bitmask: 63).models).to match_array(Tag::ModelBitmask)
      end
    end

    describe "subjects" do
      it "returns an array of subjects" do
        album = create(:album)
        artist = create(:artist)
        tag = create(:tag, model_bitmask: 63)
        create(:taglist, subject: album, tag: tag)
        create(:taglist, subject: artist, tag: tag)
        expect(tag.subjects).to match_array([album,artist])
      end
    end
  end

  describe "Class Methods" do
    it "returns the bitmask given a list of models" do
      expect(Tag.get_bitmask(["Artist", "Organization", "Source"])).to eq(22)
    end

    it "returns models when given a bitmask" do
      expect(Tag.get_models(25)).to eq(["Album","Song","Source"])
    end

    it "has methods that reverse each other" do
      shuffled = Tag::ModelBitmask.shuffle[0..2]
      expect(Tag.get_models(Tag.get_bitmask(shuffled))).to match_array(shuffled)
    end
  end

  describe "Scoping" do
    include_examples "filters by role"
    describe "filters by model" do
      let(:tag1) {create(:tag, model_bitmask: 1)} #album
      let(:tag2) {create(:tag, model_bitmask: 3)} #album, artist
      let(:tag3) {create(:tag, model_bitmask: 4)} #organization
      let(:tag4) {create(:tag, model_bitmask: 8)} #song

      it "filters by model" do
        expect(Tag.with_model("Artist")).to match_array([tag2])
      end

      it "filters by multiple models" do
        expect(Tag.with_model(["Album", "Artist"])).to match_array([tag1, tag2])
      end

      it "returns any matches on either model" do
        expect(Tag.with_model(["Artist", "Organization"])).to match_array([tag2, tag3])
      end

      it "returns all tags if nil is provided" do
        expect(Tag.with_model(nil)).to match_array([tag1, tag2, tag3, tag4])
      end

      it "returns an active record relation" do
        expect(Tag.with_model("Artist").class).to_not be_a(Array)
      end
    end
  end
end

describe Taglist do
  include_examples "global model tests" #Global Tests

  it_behaves_like "it is a polymorphic join model", Tag, [Album, Artist, Organization, Source, Song, Post], "subject"

  it "is invalid if the subject is not in the tag's bitmask" do
    tag = create(:tag, model_bitmask: 1)
    expect(build(:taglist, :with_source, tag: tag)).to_not be_valid
    expect(build(:taglist, :with_song, tag: tag)).to_not be_valid
  end

end
