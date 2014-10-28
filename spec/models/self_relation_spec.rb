require 'rails_helper'

shared_examples "a self relation" do |model_name, associated_model, relation, model_sym, model|
  
  it "has a valid factory" do
    #Gut check
    expect(create(relation)).to be_valid
  end 
  
  #Association Tests
    it "should have #{model_name}s" do
      #This should cover the association
      instance = build(relation)
      expect(instance.send(model_name + "1")).to be_a associated_model
      expect(instance.send(model_name + "2")).to be_a associated_model
    end
    
    it "should have an #{model_name}1" do
      expect(model.reflect_on_association((model_name + "1").to_sym).macro).to eq(:belongs_to)    
    end
    
    it "should have an #{model_name}2" do
      expect(model.reflect_on_association((model_name + "2").to_sym).macro).to eq(:belongs_to)        
    end  
  
  #Validation Tests
    it "is valid with two #{model_name}s and a category" do
      expect(build(relation)).to be_valid
    end
    
    it "is invalid without #{model_name}s" do
      #This should make the association fail if oen of the records is nil
      expect(build(relation, (model_name + "1").to_sym => nil)).not_to be_valid
      expect(build(relation, (model_name + "1").to_sym => nil)).not_to be_valid
    end
      
    it "is invalid when the #{model_name}s are not in the database" do
      #This should make sure that it's only using real records in the database
      expect(build(relation, (model_name + "1_id").to_sym => 999999999)).not_to be_valid
      expect(build(relation, (model_name + "2_id").to_sym => 999999999)).not_to be_valid
    end
    
    it "is invalid without a category" do
      expect(build(relation, category: nil)).not_to be_valid
    end
    
    it "is invalid with an empty category" do
      expect(build(relation, category: "")).not_to be_valid
    end
    
    it "is invalid with a category that is not in the SelfRelationship list" do
      expect(build(relation, category: "hiya")).not_to be_valid
    end
  
    it "should not have duplicate #{model_name} combinations" do
      @record1 = create(model_sym)
      @record2 = create(model_sym)
      @record3 = create(model_sym)
      expect(create(relation, (model_name + "1").to_sym => @record1, (model_name + "2").to_sym => @record2)).to be_valid
      expect(build(relation, (model_name + "1").to_sym => @record1, (model_name + "2").to_sym => @record2)).not_to be_valid
      expect(build(relation, (model_name + "1").to_sym => @record2, (model_name + "2").to_sym => @record1)).not_to be_valid
      expect(build(relation, (model_name + "1").to_sym => @record1, (model_name + "2").to_sym => @record3)).to be_valid
    end
      
    it "should not have both #{model_name}s be the same #{model_name}" do
      @record = create(model_sym)
      expect(build(relation, (model_name + "1").to_sym => @record, (model_name + "2").to_sym => @record)).to_not be_valid
    end
  

end

describe RelatedAlbums do
  it_behaves_like "a self relation", "album", Album, :related_albums, :album, RelatedAlbums
end

describe RelatedArtists do
  it_behaves_like "a self relation", "artist", Artist, :related_artists, :artist, RelatedArtists
end

describe RelatedOrganizations do
  it_behaves_like "a self relation", "organization", Organization, :related_organizations, :organization, RelatedOrganizations
end

describe RelatedSources do
  it_behaves_like "a self relation", "source", Source, :related_sources, :source, RelatedSources
end

describe RelatedSongs do 
  it_behaves_like "a self relation", "song", Song, :related_songs, :song, RelatedSongs
end
