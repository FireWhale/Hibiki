require 'rails_helper'

module TagTests
  shared_examples "it has tags" do
    model_symbol = described_class.model_name.param_key.to_sym
    
    #Associations  
      it "is valid with tags" do
        expect(build(model_symbol, :with_tag)).to be_valid
      end 
      
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
    
    #Validations
      it "is valid with multiple taglists" do
        record = create(model_symbol)
        number = Array(3..10).sample
        list = create_list(:taglist, number, subject: record)
        expect(record.taglists).to match_array(list)
        expect(record).to be_valid
      end
      
      it "is valid with multiple tags" do
        record = create(model_symbol)
        number = Array(3..10).sample
        list = create_list(:taglist, number, subject: record)
        expect(record.tags.count).to eq(number)
        expect(record).to be_valid
      end
            
      it "returns a list of tags attached to a #{model_symbol}" do
        record = create(model_symbol)
        list = create_list(:taglist, 3, subject: record)
        expect(record.tags).to eq(list.map(&:tag))
      end

  end
end
