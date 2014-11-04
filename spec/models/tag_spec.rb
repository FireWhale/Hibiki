require 'rails_helper'

describe Tag do
  #Gutcheck Test
    it "has a valid factory" do
      instance = create(:tag)
      expect(instance).to be_valid
    end
    
  #Association Test
    it "has many taglists" do
      expect(create(:tag, :with_taglist_album).taglists.first).to be_a Taglist
      expect(Tag.reflect_on_association(:taglists).macro).to eq(:has_many)
    end
    
    it "has many albums" do
      expect(create(:tag, :with_taglist_album).albums.first).to be_a Album
      expect(Tag.reflect_on_association(:albums).macro).to eq(:has_many)
    end
    
    it "has many artists" do
      expect(create(:tag, :with_taglist_artist).artists.first).to be_a Artist
      expect(Tag.reflect_on_association(:artists).macro).to eq(:has_many)
    end
    
    it "has many organizations" do
      expect(create(:tag, :with_taglist_organization).organizations.first).to be_a Organization
      expect(Tag.reflect_on_association(:organizations).macro).to eq(:has_many)
    end
    
    it "has many songs" do
      expect(create(:tag, :with_taglist_song).songs.first).to be_a Song
      expect(Tag.reflect_on_association(:songs).macro).to eq(:has_many)
    end
    
    it "has many sources" do
      expect(create(:tag, :with_taglist_source).sources.first).to be_a Source
      expect(Tag.reflect_on_association(:sources).macro).to eq(:has_many)
    end
    
    it "destroys taglists when destroyed" do
      tag = create(:tag, :with_taglist_source)
      expect{tag.destroy}.to change(Taglist, :count).by(-1)
    end
    
    it "does not destroy other records when destroyed" do
      tag = create(:tag, :with_taglist_source)
      expect{tag.destroy}.to change(Source, :count).by(0)
    end
    
  #Validation Tests   
    it "is valid with multiple taglists" do
       expect(build(:tag, :with_multiple_taglists)).to be_valid
    end
    
    include_examples "is invalid without an attribute", :tag, :name
    include_examples "is invalid without an attribute", :tag, :classification
    include_examples "is invalid without an attribute", :tag, :model_bitmask
    include_examples "is invalid without an attribute", :tag, :visibility

    include_examples "is valid with or without an attribute", :tag, :info, "This is info!"
    include_examples "is valid with or without an attribute", :tag, :synopsis, "synop"
    
    
    it "is invalid without a model_bitmask that is small enough" do
      expect(build(:tag, model_bitmask: 999999)).to_not be_valid
    end
    
    it "is invalid with duplicate name/model_bitmask" do
      expect(create(:tag, name: "hi", model_bitmask: 8)).to be_valid
      expect(build(:tag, name: "hi", model_bitmask: 8)).to_not be_valid
    end
    
    it "is valid with duplicate names if bitmask is different" do
      expect(create(:tag, name: "hi", model_bitmask: 8)).to be_valid
      expect(build(:tag, name: "hi", model_bitmask: 14)).to be_valid
    end
    
    it "is valid with duplicate bitmasks if name is different" do
      expect(create(:tag, name: "hio", model_bitmask: 14)).to be_valid
      expect(build(:tag, name: "hi", model_bitmask: 14)).to be_valid
    end
    
  #Instance Method Tests
    it "returns all records when using 'subjects'" do
      instance = create(:tag, :with_multiple_taglists)
      expect(instance.subjects.count).to eq(5)
    end
    
    it "returns models when queried" do
      expect(build(:tag, model_bitmask: 31).models).to match_array(Tag::ModelBitmask)
    end
   
  #Class Method Tests
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

describe Taglist do
  #Gutcheck Test
    it "has a valid factory" do
      expect(create(:taglist)).to be_valid
    end
  
  #Association Tests
    it "belongs to a subject" do
      expect(create(:taglist, :with_album).subject).to be_a Album
      expect(Taglist.reflect_on_association(:subject).macro).to eq(:belongs_to)      
    end
    
    it "belongs to a tag" do
      expect(create(:taglist).tag).to be_a Tag
      expect(Taglist.reflect_on_association(:tag).macro).to eq(:belongs_to)      
    end
    
    it "does not destroy the tag when destroyed" do
      taglist = create(:taglist)
      expect{taglist.destroy}.to change(Tag, :count).by(0)
    end
    
    it "des not destroy the subject when destroyed" do
      taglist = create(:taglist, :with_album)
      expect{taglist.destroy}.to change(Album, :count).by(0)      
    end
    
  #Validation Tests
    it_behaves_like "it is a polymorphic join model", :taglist, "tag", "subject", "album", ["album", "artist", "organization", "source", "song"]
    
    it "is invalid if the subject is not in the tag's bitmask" do
      tag = create(:tag, model_bitmask: 1)
      expect(build(:taglist, :with_source, tag: tag)).to_not be_valid
      expect(build(:taglist, :with_song, tag: tag)).to_not be_valid
    end
  
end
