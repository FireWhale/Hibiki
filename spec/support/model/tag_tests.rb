require 'rails_helper'

module TagTests
  shared_examples "it has tags" do
    describe "Tag Tests" do
      model_symbol = described_class.model_name.param_key.to_sym
      
      describe "Associations" do
        it "has many taglists" do
          expect(create(model_symbol, :with_tag).taglists.first).to be_a Taglist
          expect(described_class.reflect_on_association(:taglists).macro).to eq(:has_many)
        end
        
        it "has many tags" do
          expect(create(model_symbol, :with_tag).tags.first).to be_a Tag
          expect(described_class.reflect_on_association(:tags).macro).to eq(:has_many)
        end
        
        it "destroys taglists when destroyed" do
          record = create(model_symbol, :with_tag)
          expect{record.destroy}.to change(Taglist, :count).by(-1)
        end
        
        it "does not destroy tags when destroyed" do
          record = create(model_symbol, :with_tag)
          expect{record.destroy}.to change(Tag, :count).by(0)
        end
  
        it "returns a list of tags attached to a #{model_symbol}" do
          #This tests the through association
          record = create(model_symbol)
          list = create_list(:taglist, 3, subject: record)
          expect(record.tags).to match_array(list.map(&:tag))
        end
      end
      
      describe "Scopes" do
        let(:tag1) {create(:tag)}
        let(:tag2) {create(:tag)}
        let(:tag3) {create(:tag)}
        let(:tag4) {create(:tag)}
        let(:record1) {create(model_symbol)} #tags 1
        let(:record2) {create(model_symbol)} #tags 1 and 2
        let(:record3) {create(model_symbol)} #tags 2 and 3
        let(:record4) {create(model_symbol)} #no tags
        before(:each) do
          create(:taglist, subject: record1, tag: tag1)
          create(:taglist, subject: record2, tag: tag1)
          create(:taglist, subject: record2, tag: tag2)
          create(:taglist, subject: record3, tag: tag2)
          create(:taglist, subject: record3, tag: tag3)
        end
        
        it "filters by tag" do
          expect(described_class.with_tag(tag1.id)).to match_array([record1, record2])
        end
        
        it "filters by tag 2" do
          expect(described_class.with_tag(tag3.id)).to match_array([record3])
        end
        
        it "accepts multiple tags" do
          expect(described_class.with_tag([tag2.id, tag3])).to match_array([record2, record3])
        end
        
        it "returns nothing if the tag is not used" do
          expect(described_class.with_tag(tag4.id)).to eq([])
        end
        
        it "returns all records if nil is passed in" do
          expect(described_class.with_tag(nil)).to match_array([record1, record2, record3, record4])
        end
        
        it "returns no records if empty is passed into tag_ids" do
          expect(described_class.with_tag([])).to eq([])
        end
    
        it "should be an active record relation" do
          expect(described_class.with_tag(tag1.id).class).to_not be_a(Array)
        end
      end
      
    end
  end
end
