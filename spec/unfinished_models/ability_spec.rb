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
      expect(create(:tag, :with_taglist_album)).to be_valid
      expect(Tag.reflect_on_association(:albums).macro).to eq(:has_many)
    end
    
    it "has many artists" do
      expect(create(:tag, :with_taglist_artist)).to be_valid
      expect(Tag.reflect_on_association(:artists).macro).to eq(:has_many)
    end
    
    it "has many organizations" do
      expect(create(:tag, :with_taglist_organization)).to be_valid
      expect(Tag.reflect_on_association(:organizations).macro).to eq(:has_many)
    end
    
    it "has many songs" do
      expect(create(:tag, :with_taglist_song)).to be_valid
      expect(Tag.reflect_on_association(:songs).macro).to eq(:has_many)
    end
    
    it "has many sources" do
      expect(create(:tag, :with_taglist_source)).to be_valid
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
    it "is valid with a name, classification, model_bitmask, and visibility" do
      expect(build(:tag, :with_multiple_taglists)).to be_valid
    end
    
    it "is valid with multiple taglists" do
       expect(build(:tag, :with_multiple_taglists)).to be_valid
    end
    
    it "is invalid without a name" do
      expect(build(:tag, name: "")).to_not be_valid
      expect(build(:tag, name: nil)).to_not be_valid
    end
    
    it "is invalid without a classification" do
      expect(build(:tag, classification: "")).to_not be_valid
      expect(build(:tag, classification: nil)).to_not be_valid
    end
    
    it "is invalid without a model_bitmask" do
      expect(build(:tag, model_bitmask: 0)).to_not be_valid
      expect(build(:tag, model_bitmask: nil)).to_not be_valid
    end
    
    it "is invalid without a model_bitmask that is small enough" do
      expect(build(:tag, model_bitmask: 999999)).to_not be_valid
    end
    
    it "is invalid without a visibility" do
      expect(build(:tag, visibility: "")).to_not be_valid
      expect(build(:tag, visibility: nil)).to_not be_valid      
    end
    
    it "is valid without info" do
      expect(build(:tag, info: "")).to be_valid
      expect(build(:tag, info: nil)).to be_valid     
    end
    
    it "is valid without a synopsis" do
      expect(build(:tag, synopsis: "")).to be_valid
      expect(build(:tag, synopsis: nil)).to be_valid       
    end
    
    it "is invalid with duplicate name/model_bitmask" do
      expect(create(:tag, name: "hi", model_bitmask: 8)).to be_valid
      expect(build(:tag, name: "hi", model_bitmask: 8)).to_not be_valid
    end
    
    it "is valid with duplicate names" do
      expect(create(:tag, name: "hi", model_bitmask: 8)).to be_valid
      expect(build(:tag, name: "hi", model_bitmask: 14)).to be_valid
    end
    
    
  #Instance Method Tests
    it "returns all records when using 'subjects'" do
      instance = create(:tag, :with_multiple_taglists)
      expect(instance.subjects.count).to eq(5)
    end
    
    it "returns models when queried" do
      expect(build(:tag, model_bitmask: 31).models).to eq(Tag::ModelBitmask)
    end
   
  #Class Method Tests
    it "returns the bitmask given a list of models" do
      expect(Tag.get_bitmask(["Artist", "Organization", "Source"])).to eq(22)
    end
    
    it "returns models when given a bitmask" do
      expect(Tag.get_models(25)).to eq(["Album","Song","Source"])
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
    
  #Validation Tests
    it "is valid with a tag and a subject" do
      expect(build(:taglist)).to be_valid
    end
    
    it "is valid with an album" do
      expect(build(:taglist, :with_album)).to be_valid
    end
    
    it "is valid with an artist" do
      expect(build(:taglist, :with_artist)).to be_valid
    end
    
    it "is valid with an organization" do
      expect(build(:taglist, :with_organization)).to be_valid
    end
    
    it "is valid with a song" do
      expect(build(:taglist, :with_song)).to be_valid
    end
    
    it "is valid with a source" do
      expect(build(:taglist, :with_source)).to be_valid
    end
    
    it "is invalid if the subject is not in the tag's bitmask" do
      tag = create(:tag, model_bitmask: 1)
      expect(build(:taglist, :with_source, tag: tag)).to_not be_valid
    end
    
    it "is invalid without a tag" do
      expect(build(:taglist, tag: nil)).to_not be_valid
    end
    
    it "is invalid without a real tag" do
      expect(build(:taglist, tag_id: 999999999)).to_not be_valid
    end
    
    it "is invalid without a subject_type" do
      expect(build(:taglist, subject_type: nil)).to_not be_valid      
    end

    it "is invalid without a subject_id" do
      expect(build(:taglist, subject_id: nil)).to_not be_valid      
    end
    
    it "is invalid without a real event" do
      expect(build(:taglist, subject_type: "Album", subject_id: 999999999)).to_not be_valid      
    end
    
    it "should have a unique tag/subject combination" do
      @tag = create(:tag)
      @subject = create(:album)
      expect(create(:taglist, tag: @tag, subject: @subject)).to be_valid
      expect(build(:taglist, tag: @tag, subject: @subject)).to_not be_valid      
    end
  
end
