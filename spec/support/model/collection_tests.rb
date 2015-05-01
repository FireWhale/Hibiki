require 'rails_helper'

module CollectionTests
  shared_examples "it has collections" do 
    model_symbol = described_class.model_name.param_key.to_sym
      
    #Associations
      it "is valid with collectors" do
        expect(build(model_symbol, :with_collector)).to be_valid
      end 
      
      it "has many collections" do
        expect(create(model_symbol, :with_collector).collections.first).to be_a Collection
        expect(described_class.reflect_on_association(:collections).macro).to eq(:has_many)
      end
      
      it "has many collectors" do
        expect(create(model_symbol, :with_collector).collectors.first).to be_a User
        expect(described_class.reflect_on_association(:collectors).macro).to eq(:has_many)
      end
      
      it "destroys collections when destroyed" do
        record = create(model_symbol, :with_collector)
        expect{record.destroy}.to change(Collection, :count).by(-1)
      end
      
      it "does not destroy users when destroyed" do
        record = create(model_symbol, :with_collector)
        expect{record.destroy}.to change(User, :count).by(0)
      end    
      
    #Validations
      it "is valid with multiple collections" do
        record = create(model_symbol)
        number = Array(3..5).sample
        list = create_list(:collection, number, collected: record)
        expect(record.collections).to match_array(list)
        expect(record).to be_valid
      end
      
      it "is valid with multiple watchers" do
        record = create(model_symbol)
        number = Array(3..5).sample
        list = create_list(:collection, number, collected: record)    
        expect(record.collectors.count).to eq(number)    
        expect(record).to be_valid
      end
      
    #Instance Methods
      it "responds to collected?" do
        expect(build(model_symbol)).to respond_to("collected?")
      end
      
      it "returns true if user is in collected?" do
        user = create(:user)
        record = create(model_symbol)
        watchlist = create(:collection, collected: record, user: user)
        expect(record.collected?(user)).to be true
      end
      
       it "returns false if user is not in collected?" do
        user = create(:user)
        user2 = create(:user)
        record = create(model_symbol)
        watchlist = create(:collection, collected: record, user: user2)
        expect(record.collected?(user)).to be false
      end     
      
      it "returns a list of users who are collecting this #{model_symbol}" do
        #This seems redundnat and isn't an instance method anyhow
        record = create(model_symbol)
        list = create_list(:collection, 3, collected: record)
        expect(record.collectors).to eq(list.map(&:user))
      end
    
  end
end
