require 'rails_helper'

module AssociationTests
  shared_examples "it has a primary relation" do |model, model2, relation, relation_symbol|
    #Associations
      it "has many #{relation.to_s}s" do
        expect(create(model, :with_primary_relations).send("#{relation_symbol.to_s}s").first).to be_a relation
        expect(model.to_s.capitalize.constantize.reflect_on_association("#{relation_symbol}s".to_sym).macro).to eq(:has_many)
      end
      
      it "has many #{model2}s" do
        expect(create(model, :with_primary_relations).send("#{model2}s").first).to be_a model2.capitalize.constantize
        expect(model.to_s.capitalize.constantize.reflect_on_association("#{model2}s".to_sym).macro).to eq(:has_many)
      end
      
      it "destroys #{relation.to_s} when destroyed" do
        record = create(model, :with_primary_relations)
        expect{record.destroy}.to change(relation, :count).by(-1)
      end
            
      it "does not dsetroy #{model2} when destroyed" do
        record = create(model, :with_primary_relations)
        expect{record.destroy}.to change(model2.capitalize.constantize, :count).by(0)
      end
    
    #Validations
      it_behaves_like "association validations", model, model2, relation_symbol.to_s
  end
  
  shared_examples "it has self-relations" do |model_symbol, model, relation|
    #Associations 
      it "has many related_#{model}_relations1" do
        expect(create(model_symbol, :with_self_relation).send("related_#{model}_relations1").first).to be_a relation
        expect(model.capitalize.constantize.reflect_on_association("related_#{model}_relations1".to_sym).macro).to eq(:has_many)
      end

      it "has many related_#{model}_relations2" do
        expect(create(model_symbol, :with_self_relation).send("related_#{model}_relations2").first).to be_a relation
        expect(model.capitalize.constantize.reflect_on_association("related_#{model}_relations2".to_sym).macro).to eq(:has_many)
      end      
      
      it "has many related_#{model}s1" do
        expect(create(model_symbol, :with_self_relation).send("related_#{model}s1").first).to be_a model.capitalize.constantize
        expect(model.capitalize.constantize.reflect_on_association("related_#{model}s1".to_sym).macro).to eq(:has_many)
      end
      
      it "has many related_#{model}s1" do
        expect(create(model_symbol, :with_self_relation).send("related_#{model}s2").first).to be_a model.capitalize.constantize
        expect(model.capitalize.constantize.reflect_on_association("related_#{model}s2".to_sym).macro).to eq(:has_many)
      end      
      
      it "destroys related_#{model}_relations when destroyed" do
        #:with_self_relation creates 3 model records and 2 self_relation records, btw
        record = create(model_symbol, :with_self_relation)
        expect{record.destroy}.to change(relation, :count).by(-2)
      end     
      
      it "does not destroy related #{model}s when destroyed" do
        record = create(model_symbol, :with_self_relation)
        expect{record.destroy}.to change(model.capitalize.constantize, :count).by(-1)
      end 
      
    #Validation    

      it "is valid with multiple #{model}1s" do
        record = create(model_symbol)
        number = Array(3..10).sample
        list = create_list("related_#{model}s".to_sym, number, ("#{model}1").to_sym => record)
        expect(record.send("related_#{model}s1").count).to eq(number)
        expect(record).to be_valid                
      end
      
      it "is valid with multiple #{model}2s" do
        record = create(model_symbol)
        number = Array(3..10).sample
        list = create_list("related_#{model}s".to_sym, number, ("#{model}2").to_sym => record)
        expect(record.send("related_#{model}s2").count).to eq(number)
        expect(record).to be_valid                
      end
      
      it "is valid with multiple related_#{model}_relations1" do
        record = create(model_symbol)
        number = Array(3..10).sample
        list = create_list("related_#{model}s".to_sym, number, ("#{model}1").to_sym => record)
        expect(record.send("related_#{model}_relations1")).to match_array(list)
        expect(record).to be_valid        
      end
      
      it "is valid with mulitple related_#{model}_relations2" do
        record = create(model_symbol)
        number = Array(3..10).sample
        list = create_list("related_#{model}s".to_sym, number, ("#{model}2").to_sym => record)
        expect(record.send("related_#{model}_relations2")).to match_array(list)
        expect(record).to be_valid        
      end
      
      it "is invalid without a real #{model}1" do
        record = create(model_symbol)
        expect(build(("related_#{model}s").to_sym, ("#{model}2").to_sym => record, ("#{model}1_id").to_sym => 999999)).to_not be_valid
      end
      
      it "is invalid without a real #{model}2" do
        record = create(model_symbol)
        expect(build(("related_#{model}s").to_sym, ("#{model}1").to_sym => record, ("#{model}2_id").to_sym => 999999)).to_not be_valid
      end
      
    #Instance Methods
      it "responds to '.related_#{model}s'" do
        expect(create(model_symbol)).to respond_to("related_#{model}s")
      end
      
      it "responds to '.related_#{model}_relations'" do
        expect(create(model_symbol)).to respond_to("related_#{model}_relations")
      end
      
      it "returns a list of related#{model}_relations" do
        record1 = create(model_symbol)
        relation1 = create(("related_#{model}s").to_sym, ("#{model}1").to_sym => record1)
        relation2 = create(("related_#{model}s").to_sym, ("#{model}2").to_sym => record1)
        expect(record1.send("related_#{model}_relations")).to match_array([relation1, relation2])
      end
      
      it "returns a list of related #{model}s" do
         record1 = create(model_symbol)
        record2 = create(model_symbol)
        record3 = create(model_symbol)
        relation1 = create(("related_#{model}s").to_sym, ("#{model}1").to_sym => record1, ("#{model}2").to_sym => record2)
        relation2 = create(("related_#{model}s").to_sym, ("#{model}1").to_sym => record3, ("#{model}2").to_sym => record1)
        expect(record1.send("related_#{model}s")).to match_array([record2, record3])       
      end
      
    end
    
  shared_examples "it has_many" do |model, model2, join_table, join_model, trait|
    #Associations
      it "has many #{join_model.to_s}s" do
        expect(create(model, trait).send("#{join_table}s").first).to be_a join_model      
        expect(model.to_s.capitalize.constantize.reflect_on_association("#{join_table}s".to_sym).macro).to eq(:has_many)
      end
      
      it "has many #{model2}s" do
        expect(create(model, trait).send("#{model2}s").first).to be_a model2.capitalize.constantize
        expect(model.to_s.capitalize.constantize.reflect_on_association("#{model2}s".to_sym).macro).to eq(:has_many)
      end
      
      it "destroys #{join_model.to_s}s when destroyed" do
        record = create(model, trait)
        expect{record.destroy}.to change(join_model, :count).by(-1)
      end
      
      it "does not destroy #{model2}s when destroyed" do
        record = create(model, trait)
        expect{record.destroy}.to change(model2.capitalize.constantize, :count).by(0)      
      end
 
    #Validation    
      it_behaves_like "association validations", model, model2, join_table
  end

  shared_examples "a join table" do |model, model_1, model_2, model_class|
    #Associations
      it "belongs to a #{model_1}" do
        expect(create(model).send(model_1)).to be_a model_1.capitalize.constantize
        expect(model_class.reflect_on_association(model_1.to_sym).macro).to eq(:belongs_to)
      end
      
      it "belongs to a #{model_2}" do
        expect(create(model).send(model_2)).to be_a model_2.capitalize.constantize
        expect(model_class.reflect_on_association(model_2.to_sym).macro).to eq(:belongs_to)      
      end
    
    #Validation
      it "is valid with a #{model_1} and a #{model_2}" do
        expect(build(model)).to be_valid
      end
      
      it "is invalid without a #{model_1}" do
        expect(build(model, model_1.to_sym => nil)).to_not be_valid
      end
      
      it "is invalid without a real #{model_1}" do
        expect(build(model, (model_1 + "_id").to_sym => 999999999)).to_not be_valid
      end
  
      it "is invalid without a #{model_2}" do
        expect(build(model, model_2.to_sym => nil)).to_not be_valid
      end
      
      it "is invalid without a real #{model_2}" do
        expect(build(model, (model_2 + "_id").to_sym => 999999999)).to_not be_valid
      end
          
      it "should have a unique #{model_1}/#{model_2} combination" do
        @model1 = create(model_1.to_sym)
        @model2 = create(model_2.to_sym)
        expect(create(model, model_1.to_sym => @model1, model_2.to_sym => @model2)).to be_valid
        expect(build(model, model_1.to_sym => @model1, model_2.to_sym => @model2)).to_not be_valid
      end
  end
  
  shared_examples "it is a polymorphic join model" do |model, polymodel, association, example, list|
      
    #Validations
      it "is valid with a #{polymodel}" do
        record = create(polymodel)
        expect(build(model, polymodel.to_sym => record)).to be_valid
      end
      
      list.each do |model2|
        it "is valid with an #{model2}" do
          expect(build(model, "with_#{model2}".to_sym)).to be_valid
        end
      end
      
      it "is invalid without a #{polymodel}" do
        expect(build(model, polymodel.to_sym => nil)).to_not be_valid
      end
      
      it "is invalid without a real #{polymodel}" do
        expect(build(model, "#{polymodel}_id".to_sym => 9999999)).to_not be_valid
      end
  
      it "is invalid without a #{association}_type" do
        expect(build(model, "#{association}_type" => nil)).to_not be_valid      
      end
      
      it "is invalid without a #{association}_id" do
        expect(build(model, "#{association}_id" => nil)).to_not be_valid      
      end
      
      it "is invalid without a real #{association}" do
        expect(build(model, "#{association}_type" => example.capitalize, "#{association}_id" => 9999999999)).to_not be_valid      
      end
      
      it "is valid with unique #{polymodel}/#{association}_type combinations" do
        @polymodel = create(polymodel.to_sym)
        expect(create(model, polymodel.to_sym => @polymodel)).to be_valid
        expect(build(model, polymodel.to_sym => @polymodel)).to be_valid   
      end
      
      it "is invalid with a unique #{polymodel}/#{association} combination" do
        @polymodel = create(polymodel.to_sym)
        @association = create(example.to_sym)
        expect(create(model, polymodel.to_sym => @polymodel, "#{association}" => @association)).to be_valid
        expect(build(model, polymodel.to_sym => @polymodel, "#{association}" => @association)).to_not be_valid      
      end

  end
  
  shared_examples "association validations" do |model, model2, join_table|
    #Validations
      it "is invalid without a real #{model2}" do
        record = create(model)
        expect(build(join_table.to_sym, model => record, ("#{model2}_id").to_sym => 999999)).to_not be_valid
      end
          
      it "is valid with multiple #{join_table}s" do
        record = create(model)
        number = Array(3..10).sample
        list = create_list(join_table.to_sym, number, model => record)
        expect(record.send("#{join_table}s")).to match_array(list)
        expect(record).to be_valid
      end
      
      it "is valid with multiple #{model2}s" do
        record = create(model)
        number = Array(3..10).sample
        list = create_list(join_table.to_sym, number, model => record)
        expect(record.send("#{model2}s").count).to eq(number)
        expect(record).to be_valid
      end  
  end
  
end
