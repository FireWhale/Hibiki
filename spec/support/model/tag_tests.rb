require 'rails_helper'

module TagTests
  shared_examples "it has tags" do |model, model_class|
    #Associations  
      it "is valid with tags" do
        expect(build(model, :with_tag)).to be_valid
      end 
      
      it "has many taglists" do
        expect(create(model, :with_tag).taglists.first).to be_a Taglist
        expect(model_class.reflect_on_association(:taglists).macro).to eq(:has_many)
      end
      
      it "has many tags" do
        expect(create(model, :with_tag).tags.first).to be_a Tag
        expect(model_class.reflect_on_association(:tags).macro).to eq(:has_many)
      end
      
      it "destroys taglists when destroyed" do
        record = create(model, :with_tag)
        expect{record.destroy}.to change(Taglist, :count).by(-1)
      end
      
      it "does not destroy tags when destroyed" do
        record = create(model, :with_tag)
        expect{record.destroy}.to change(Tag, :count).by(0)
      end
    
    #Validations
      it "is valid with multiple taglists and tags" do
        record = create(model)
        number = Array(3..10).sample
        list = create_list(:taglist, number, subject: record)
        expect(record.taglists).to match_array(list)
        expect(record.tags.count).to eq(number)
        expect(record).to be_valid
      end
  end
end
