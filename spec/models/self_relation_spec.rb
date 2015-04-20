require 'rails_helper'

shared_examples "a self relation" do |primary_class|
  primary_class_string = primary_class.model_name.singular
  primary_class_symbol = primary_class.model_name.param_key.to_sym
  self_relation_class_symbol = described_class.model_name.param_key.to_sym
  
  include_examples "global model tests" 
  
  describe "Association Tests" do
    it "should have an #{primary_class_string}1" do
      expect(build(self_relation_class_symbol).send("#{primary_class_string}1")).to be_a primary_class
      expect(described_class.reflect_on_association("#{primary_class_string}1".to_sym).macro).to eq(:belongs_to)
    end
    
    it "should have an #{primary_class_string}2" do
      expect(build(self_relation_class_symbol).send("#{primary_class_string}2")).to be_a primary_class
      expect(described_class.reflect_on_association("#{primary_class_string}2".to_sym).macro).to eq(:belongs_to)
    end
    
    it "should not destroy #{primary_class_string}s when destroyed" do
      record = create(self_relation_class_symbol)
      expect{record.destroy}.to change(primary_class, :count).by(0)
    end
  end
  
  describe "Validation Tests" do
    it "is valid with two #{primary_class_string}s and a category" do
      expect(build(self_relation_class_symbol)).to be_valid
    end
    
    it "is invalid without either #{primary_class_string}s" do
      expect(build(self_relation_class_symbol, "#{primary_class_string}1".to_sym => nil)).not_to be_valid
      expect(build(self_relation_class_symbol, "#{primary_class_string}2".to_sym => nil)).not_to be_valid      
    end
    
    it "is invalid without either #{primary_class_string}s not actually existing" do
      expect(build(self_relation_class_symbol, "#{primary_class_string}1_id".to_sym => 999999999)).not_to be_valid
      expect(build(self_relation_class_symbol, "#{primary_class_string}2_id".to_sym => 999999999)).not_to be_valid      
    end
    
    include_examples "is invalid without an attribute", :category
    
    if primary_class == Artist
      include_examples "is invalid without an attribute in a category", :category, primary_class::SelfRelationships.reject {|r| r.count < 3}.map(&:last), "#{primary_class_string}::SelfRelationships"            
    else
      include_examples "is invalid without an attribute in a category", :category, primary_class::SelfRelationships.map { |e| e[3]}.reject(&:nil?), "#{primary_class_string}::SelfRelationships"
    end
    
    it "should not have reverse duplicate #{primary_class_string} combinations" do
      record1 = create(primary_class_symbol)
      record2 = create(primary_class_symbol)
      record3 = create(primary_class_symbol)
      expect(create(self_relation_class_symbol, "#{primary_class_string}1".to_sym => record1, "#{primary_class_string}2".to_sym => record2)).to be_valid
      expect(build(self_relation_class_symbol, "#{primary_class_string}1".to_sym => record1, "#{primary_class_string}2".to_sym => record2)).not_to be_valid
      expect(build(self_relation_class_symbol, "#{primary_class_string}1".to_sym => record2, "#{primary_class_string}2".to_sym => record1)).not_to be_valid
      expect(build(self_relation_class_symbol, "#{primary_class_string}1".to_sym => record1, "#{primary_class_string}2".to_sym => record3)).to be_valid 
    end    
    
    it "should not have both #{primary_class_string}s be the same #{primary_class_string}" do
      record = create(primary_class_symbol)
      expect(build(self_relation_class_symbol, "#{primary_class_string}1".to_sym => record, "#{primary_class_string}2".to_sym => record)).not_to be_valid
    end
  end
end


describe RelatedAlbums do
  it_behaves_like "a self relation", Album
end

describe RelatedArtists do
  it_behaves_like "a self relation", Artist
end

describe RelatedOrganizations do
  it_behaves_like "a self relation", Organization
end

describe RelatedSources do
  it_behaves_like "a self relation", Source
end

describe RelatedSongs do 
  it_behaves_like "a self relation", Song
end
