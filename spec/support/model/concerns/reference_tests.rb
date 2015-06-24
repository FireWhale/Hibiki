require 'rails_helper'

module ReferenceTests
  shared_examples "it has references" do 
    describe "Reference Tests" do
      model_symbol = described_class.model_name.param_key.to_sym
      
      describe "Associations" do
        it "has many references" do
          expect(create(model_symbol, :with_reference).references.first).to be_a Reference
          expect(described_class.reflect_on_association(:references).macro).to eq(:has_many)
        end
                
        it "destroys references when destroyed" do
          record = create(model_symbol, :with_reference)
          expect{record.destroy}.to change(Reference, :count).by(-1)
        end
      end
        
      describe "Instance Methods" do
        it "returns a list of references for a #{model_symbol} aka super" do
          record = create(model_symbol)
          reference1 = create(:reference, model: record, site_name: "VGMdb")
          reference2 = create(:reference, model: record, site_name: "Wikipedia")
          expect(record.references).to match_array([reference1, reference2])
        end
        
        it "returns a specific reference if passed in as a parameter" do
          record = create(model_symbol)
          reference1 = create(:reference, model: record, site_name: "VGMdb")
          reference2 = create(:reference, model: record, site_name: "Wikipedia")
          expect(record.references("Wikipedia")).to eq(reference2)
        end
        
        it "accepts the one word references as a symbol" do
          record = create(model_symbol)
          reference1 = create(:reference, model: record, site_name: "VGMdb")
          reference2 = create(:reference, model: record, site_name: "Wikipedia")
          expect(record.references(:Wikipedia)).to eq(reference2)          
        end
        
        it "returns nil if the specific reference site is not in the references" do
          record = create(model_symbol)
          reference = create(:reference, model: record)
          expect(record.references("hi")).to be_nil
        end
      end      
    end
  end
end
