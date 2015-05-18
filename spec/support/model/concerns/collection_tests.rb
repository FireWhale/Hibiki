require 'rails_helper'

module CollectionTests
  shared_examples "it has collections" do 
    describe "Collection Tests" do
      model_symbol = described_class.model_name.param_key.to_sym
      
      describe "Associations" do
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
          
        it "is valid with multiple watchers" do
          #This tests the :through option
          record = create(model_symbol)
          number = Array(3..5).sample
          list = create_list(:collection, number, collected: record)    
          expect(record.collectors).to eq(list.map(&:user))    
        end
      end
      
      describe "Instance Methods" do
        describe "collected?" do
          it "responds to collected?" do
            expect(build(model_symbol)).to respond_to("collected?")
          end
          
          it "returns true if user is in collected?" do
            user = create(:user)
            record = create(model_symbol)
            collection = create(:collection, collected: record, user: user)
            expect(record.collected?(user)).to be true
          end
          
           it "returns false if user is not in collected?" do
            user = create(:user)
            user2 = create(:user)
            record = create(model_symbol)
            collection = create(:collection, collected: record, user: user2)
            expect(record.collected?(user)).to be false
          end        
        end
       
        describe "collected_category" do
          let(:record) {create(model_symbol)}
          let(:user) {create(:user)}
          
          it "responds to collected_category" do
            expect(build(model_symbol)).to respond_to("collected_category")
          end
          
          it "returns '' with no user" do
            collection = create(:collection, user: user, collected: record)
            expect(record.collected_category(nil)).to eq('')            
          end
          
          it "returns '' if there's no collection" do
            expect(record.collected_category(user)).to eq('')
          end
          
          it "returns the relationship" do
            collection = create(:collection, user: user, collected: record)
            expect(record.collected_category(user)).to eq(collection.relationship)
          end  
          
        end
      end
      
      describe "Scopes" do
        model_symbol = described_class.model_name.param_key.to_sym
        let(:record1) {create(model_symbol)}
        let(:record2) {create(model_symbol)}
        let(:record3) {create(model_symbol)}
        let(:record4) {create(model_symbol)}
        let(:record5) {create(model_symbol)}
        let(:record6) {create(model_symbol)}
        let(:user1) {create(:user)} # Basic
        let(:user2) {create(:user)} # Tests types of favorites
        let(:user3) {create(:user)} # has a mix of favorites
        let(:user4) {create(:user)} # Does not have any collections
  
        before(:each) do
          create(:collection, user: user1, collected: record1, relationship: "Collected")
          create(:collection, user: user1, collected: record2, relationship: "Collected")
          create(:collection, user: user1, collected: record3, relationship: "Wishlisted")
          create(:collection, user: user2, collected: record1, relationship: "Collected")
          create(:collection, user: user2, collected: record4, relationship: "Ignored")
          create(:collection, user: user2, collected: record5, relationship: "Wishlisted")
          create(:collection, user: user2, collected: record6, relationship: "Collected")
          create(:collection, user: user3, collected: record1, relationship: "Collected")
          create(:collection, user: user3, collected: record5, relationship: "Ignored")
          create(:collection, user: user3, collected: record2, relationship: "Ignored")
        end
          
        describe "it filters by collection" do
          it "matches a single user" do
            expect(described_class.in_collection(user1)).to match_array([record1,record2, record3])
          end
          
          it "matches several users" do
            expect(described_class.in_collection([user1,user2])).to match_array([record1,record2,record3,record4, record5,record6])
          end
          
          it "matches a category" do
            expect(described_class.in_collection(user1, "Collected")).to match_array([record1,record2])          
          end
          
          it "matches multiple categories" do
            expect(described_class.in_collection(user2, ["Collected", "Wishlisted"])).to match_array([record1,record5, record6])          
          end
          
          it "returns all if user is nil" do
            expect(described_class.in_collection(nil)).to match_array([record1,record2, record3, record4, record5, record6])          
          end
          
          it "ignores the second parameter if users are nil" do
            expect(described_class.in_collection(nil, "Collected")).to match_array([record1,record2, record3, record4, record5, record6])                   
          end
          
          it "ignores a nil favorite string" do
            expect(described_class.in_collection(user3, nil)).to match_array([record1,record2, record5])          
          end
          
          it "is an active record relation" do
            expect(described_class.in_collection(user3.id).class).to_not be_a(Array)
          end
        end
          
        describe "it filters by not in collection" do
          it "removes albums that are in the user's collection" do
            expect(described_class.not_in_collection(user1)).to match_array([record4,record5, record6])
          end
          
          it "removes albums that are in any of the users' collection" do
            expect(described_class.not_in_collection([user3.id, user2.id])).to match_array([record3])
          end
          
          it "removes records based on either user" do
            expect(described_class.not_in_collection([user1.id, user3.id])).to match_array([record4, record6])
          end
          
          it "returns all records if nil is passed in" do
            expect(described_class.not_in_collection(nil)).to match_array([record1,record2, record3, record4, record5, record6])
          end
          
          it "is an active record relation" do
            expect(described_class.not_in_collection(user3.id).class).to_not be_a(Array)
          end
        end
          
        describe "it joints the two and returns any albums that match" do
          it "returns records that match either filter" do
            expect(described_class.collection_filter(user2.id, ['Collected'], user3.id)).to match_array([record1,record3,record4,record6])          
          end
          
          it "will return records that are filtered by the other" do
            expect(described_class.collection_filter(user1.id, ['Wishlisted'], user1.id)).to match_array([record5,record3,record4,record6])                    
          end
          
          it "returns all records if nil is passed into user1" do
            expect(described_class.collection_filter(nil, ['Collected', 'Ignored', 'Wishlisted'], user2.id)).to match_array([record1,record2,record3,record4,record5,record6])
          end
          
          it "returns all records if nil is passed into user2" do
            expect(described_class.collection_filter(user1.id, ['Collected', 'Ignored', 'Wishlisted'], nil)).to match_array([record1,record2,record3,record4,record5,record6])         
          end
          
          it "returns all records if [c, i, w] is passed in with the same user" do
            expect(described_class.collection_filter(user1.id, ['Collected', 'Ignored', 'Wishlisted'], user1.id)).to match_array([record1,record2,record3,record4,record5,record6])
          end
          
          it "returns an active record relation" do
            expect(described_class.collection_filter(user1.id, 'Collected', user2.id).class).to_not be_a(Array)
          end
        end
      end
      
    end
  end
end
