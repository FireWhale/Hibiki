require 'rails_helper'

module SelfAssociationTests
  shared_examples "it has self-relations" do 
    describe "Self Relation Tests" do
      model_symbol = described_class.model_name.param_key.to_sym
      model_string = described_class.model_name.singular
      join_model_class = "Related#{model_string.capitalize}s".constantize
      join_model_symbol = join_model_class.model_name.param_key.to_sym
      
      describe 'Associations' do
        it "has many related_#{model_string}_relations1" do
          expect(create(model_symbol, :with_self_relation).send("related_#{model_string}_relations1").first).to be_a join_model_class
          expect(described_class.reflect_on_association("related_#{model_string}_relations1".to_sym).macro).to eq(:has_many)
        end
  
        it "has many related_#{model_string}_relations2" do
          expect(create(model_symbol, :with_self_relation).send("related_#{model_string}_relations2").first).to be_a join_model_class
          expect(described_class.reflect_on_association("related_#{model_string}_relations2".to_sym).macro).to eq(:has_many)
        end      
        
        it "has many related_#{model_string}s1" do
          expect(create(model_symbol, :with_self_relation).send("related_#{model_string}s1").first).to be_a described_class
          expect(described_class.reflect_on_association("related_#{model_string}s1".to_sym).macro).to eq(:has_many)
        end
        
        it "has many related_#{model_string}s1" do
          expect(create(model_symbol, :with_self_relation).send("related_#{model_string}s2").first).to be_a described_class
          expect(described_class.reflect_on_association("related_#{model_string}s2".to_sym).macro).to eq(:has_many)
        end        

        it "destroys related_#{model_string}_relations when destroyed" do
          #:with_self_relation creates 3 model records and 2 self_relation records, btw
          record = create(model_symbol, :with_self_relation)
          expect{record.destroy}.to change(join_model_class, :count).by(-2)
        end     
        
        it "does not destroy related #{model_string}s when destroyed" do
          record = create(model_symbol, :with_self_relation)
          expect{record.destroy}.to change(described_class, :count).by(-1) #It did destroy itself, after all.
        end
        
        it "has related_#{model_string}s2 through related_#{model_string}_relations" do
          record = create(model_symbol)
          list = create_list(join_model_symbol, 5, ("#{model_string}2").to_sym => record)
          expect(record.send("related_#{model_string}s2")).to match_array(list.map(&"#{model_string}1".to_sym))
        end

        it "has related_#{model_string}s1 through related_#{model_string}_relations" do
          record = create(model_symbol)
          list = create_list(join_model_symbol, 5, ("#{model_string}1").to_sym => record)
          expect(record.send("related_#{model_string}s1")).to match_array(list.map(&"#{model_string}2".to_sym))
        end
      end
      
      describe 'Instance Methods' do
        it "responds to '.related_#{model_string}s'" do
          expect(create(model_symbol)).to respond_to("related_#{model_string}s")
        end
        
        it "responds to '.related_#{model_string}_relations'" do
          expect(create(model_symbol)).to respond_to("related_#{model_string}_relations")
        end
        
        it "returns a list of related_#{model_string}_relations" do
          record1 = create(model_symbol)
          relation1 = create(join_model_symbol, ("#{model_string}1").to_sym => record1)
          relation2 = create(join_model_symbol, ("#{model_string}2").to_sym => record1)
          expect(record1.send("related_#{model_string}_relations")).to match_array([relation1, relation2])
        end
        
        it "returns an active_record association class with related_#{model_string}_relations" do
          record1 = create(model_symbol)
          relation1 = create(join_model_symbol, ("#{model_string}1").to_sym => record1)
          expect(record1.send("related_#{model_string}_relations")).to_not be_a(Array)
        end
        
        it "returns an active_record association class with related_#{model_string}s" do
          record1 = create(model_symbol)
          relation1 = create(join_model_symbol, ("#{model_string}1").to_sym => record1)
          expect(record1.send("related_#{model_string}s")).to_not be_a(Array)
        end      
        
        it "returns a list of related #{model_string}s" do
          record1 = create(model_symbol)
          record2 = create(model_symbol)
          record3 = create(model_symbol)
          relation1 = create(join_model_symbol, ("#{model_string}1").to_sym => record1, ("#{model_string}2").to_sym => record2)
          relation2 = create(join_model_symbol, ("#{model_string}1").to_sym => record3, ("#{model_string}2").to_sym => record1)
          expect(record1.send("related_#{model_string}s")).to match_array([record2, record3])       
        end        
      end
      
      describe 'Scopes' do
        unless described_class == Artist
          relationships = described_class.const_get("SelfRelationships").map { |relation| relation[3]}.reject(&:nil?)
        else
          relationships = described_class.const_get("SelfRelationships").reject {|r| r.count < 3}.map(&:last)
        end
        let(:record1) {create(model_symbol)}
        let(:record2) {create(model_symbol)} #limited edition of 1
        let(:record3) {create(model_symbol)} #limited edition of 1
        let(:record4) {create(model_symbol)} #reprint of 1
        let(:record5) {create(model_symbol)} #reprint of 4 and LE of 3
        let(:record6) {create(model_symbol)} 
        let(:relationship1) {relationships.sample}
        let(:relationship2) {(relationships - [relationship1]).sample}
        let(:relationship3) {(relationships - [relationship1, relationship2]).sample}
        before(:each) do
          create(join_model_symbol, "#{model_symbol}1".to_sym => record2, "#{model_symbol}2".to_sym => record1, category: relationship1)
          create(join_model_symbol, "#{model_symbol}1".to_sym => record3, "#{model_symbol}2".to_sym => record1, category: relationship1)
          create(join_model_symbol, "#{model_symbol}1".to_sym => record4, "#{model_symbol}2".to_sym => record1, category: relationship2)
          create(join_model_symbol, "#{model_symbol}1".to_sym => record5, "#{model_symbol}2".to_sym => record4, category: relationship2)
          create(join_model_symbol, "#{model_symbol}1".to_sym => record5, "#{model_symbol}2".to_sym => record3, category: relationship1)
        end        
        
        describe "Has a category" do
          it "filters by a category" do
            expect(described_class.with_self_relation_categories(relationship1)).to match_array([record2, record3, record5])
          end
          
          it "filters by multiple categories" do
            expect(described_class.with_self_relation_categories([relationship1, relationship2])).to match_array([record2, record3, record4, record5])
          end
          
          it "returns nothing if there are no matches" do
            expect(described_class.with_self_relation_categories(["yo"])).to match_array([])
          end
          
          it "matches on any category" do
            expect(described_class.with_self_relation_categories(relationship2)).to match_array([record4, record5])        
          end
          
          it "returns all records if nil is passed in" do
            expect(described_class.with_self_relation_categories(nil)).to match_array([record1, record2, record3, record4, record5, record6])        
          end
          
          it "should be an active record relation" do
            expect(described_class.with_self_relation_categories(relationship1).class).to_not be_a(Array)
          end
        end
        
        describe "does not have a category" do
          it "filters by removing records with a certain category" do
            expect(described_class.without_self_relation_categories(relationship1)).to match_array([record1, record4, record6])
          end
          
          it "filters by removing records with a certain multiple categories" do
            expect(described_class.without_self_relation_categories([relationship1, relationship2])).to match_array([record1, record6])
          end
          
          it "filters by removing records matching on either category" do
            expect(described_class.without_self_relation_categories(relationship2)).to match_array([record1, record2, record3, record6])        
          end
          
          it "returns all records if nil is passed in"  do
            expect(described_class.without_self_relation_categories(nil)).to match_array([record1, record2, record3, record4, record5, record6])        
          end
          
          it "should be an active record relation" do
            expect(described_class.without_self_relation_categories("hi").class).to_not be_a(Array)
          end
        end
              
              
        describe "does have a cateogy and does not have others" do
          it "returns records that matches either filter" do
            expect(described_class.filters_by_self_relation_categories([relationship1], "hey!")).to match_array([record1, record2, record3, record4, record5, record6])                
          end
          
          it "returns records that match the filter" do
            expect(described_class.filters_by_self_relation_categories([relationship1], relationship2)).to match_array([record1, record2, record3, record5, record6])         
          end
    
          it "returns records that match the filter 2" do
            expect(described_class.filters_by_self_relation_categories([relationship2], relationship1)).to match_array([record1, record4, record5, record6])         
          end
          
          it "returns all records if nil is passed into both" do
            expect(described_class.filters_by_self_relation_categories(nil, nil)).to match_array([record1, record2, record3, record4, record5, record6])           
          end
          
          it "filters out as much as posssible" do
            expect(described_class.filters_by_self_relation_categories("hi", [relationship1, relationship2])).to match_array([record1, record6])           
          end
          
          it "returns all records if the same category is passed into both params" do
            expect(described_class.filters_by_self_relation_categories([relationship1], relationship1)).to match_array([record1, record2, record3, record4, record5, record6])       
          end
          
          it "should be an active record relation" do
            expect(described_class.filters_by_self_relation_categories("hey", "hi").class).to_not be_a(Array)
          end
        end
        
      end
      
    end
  end
end
