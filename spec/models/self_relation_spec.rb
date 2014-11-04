require 'rails_helper'

shared_examples "a self relation" do |model_name, associated_model, relation, model_sym, model|
  
  it "has a valid factory" do
    #Gut check
    expect(create(relation)).to be_valid
  end 
  
  #Association Tests    
    it "should have an #{model_name}1" do
      expect(build(relation).send(model_name + "1")).to be_a associated_model
      expect(model.reflect_on_association((model_name + "1").to_sym).macro).to eq(:belongs_to)    
    end
    
    it "should have an #{model_name}2" do
      expect(build(relation).send(model_name + "2")).to be_a associated_model
      expect(model.reflect_on_association((model_name + "2").to_sym).macro).to eq(:belongs_to)        
    end  
    
    it "should not destroy #{model_name}s" do
      record = create(relation)
      expect{record.destroy}.to change(associated_model, :count).by(0)
    end
  
  #Validation Tests
    it "is valid with two #{model_name}s and a category" do
      expect(build(relation)).to be_valid
    end
    
    it "is invalid without #{model_name}s" do
      #This should make the association fail if oen of the records is nil
      expect(build(relation, (model_name + "1").to_sym => nil)).not_to be_valid
      expect(build(relation, (model_name + "2").to_sym => nil)).not_to be_valid
    end
      
    it "is invalid when the #{model_name}s are not in the database" do
      #This should make sure that it's only using real records in the database
      expect(build(relation, (model_name + "1_id").to_sym => 999999999)).not_to be_valid
      expect(build(relation, (model_name + "2_id").to_sym => 999999999)).not_to be_valid
    end
    
    include_examples "is invalid without an attribute", relation, :category
    if model_sym == :artist
      include_examples "is invalid without an attribute in a category", relation, :category, associated_model::SelfRelationships.reject {|r| r.count < 3}.map(&:last), "#{associated_model}::SelfRelationships"      
    else
      include_examples "is invalid without an attribute in a category", relation, :category, associated_model::SelfRelationships.map { |e| e[3]}.reject(&:nil?), "#{associated_model}::SelfRelationships"
      
    end
  
    it "should not have reverse duplicate #{model_name} combinations" do
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
