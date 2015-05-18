require 'rails_helper'

module WatchlistTests
  shared_examples "it has watchlists" do 
    describe "Watchlist Tests" do
      model_symbol = described_class.model_name.param_key.to_sym
      
      describe "Associations" do
        it "has many watchlists" do
          expect(create(model_symbol, :with_watcher).watchlists.first).to be_a Watchlist
          expect(described_class.reflect_on_association(:watchlists).macro).to eq(:has_many)
        end
        
        it "has many watchers" do
          expect(create(model_symbol, :with_watcher).watchers.first).to be_a User
          expect(described_class.reflect_on_association(:watchers).macro).to eq(:has_many)
        end
        
        it "destroys watchlists when destroyed" do
          record = create(model_symbol, :with_watcher)
          expect{record.destroy}.to change(Watchlist, :count).by(-1)
        end
        
        it "does not destroy users when destroyed" do
          record = create(model_symbol, :with_watcher)
          expect{record.destroy}.to change(User, :count).by(0)
        end
          
        it "returns a list of users who are watching this #{model_symbol}" do
          #This tests the :through
          record = create(model_symbol)
          list = create_list(:watchlist, 3, watched: record)
          expect(record.watchers).to eq(list.map(&:user))
        end
      end
      
      describe "Instance Methods" do
        it "responds to watched?" do
          expect(build(model_symbol)).to respond_to("watched?")
        end
        
        it "returns true if user is in watched?" do
          user = create(:user)
          record = create(model_symbol)
          watchlist = create(:watchlist, watched: record, user: user)
          expect(record.watched?(user)).to be true
        end
        
         it "returns false if user is not in watched?" do
          user = create(:user)
          user2 = create(:user)
          record = create(model_symbol)
          watchlist = create(:watchlist, watched: record, user: user2)
          expect(record.watched?(user)).to be false
        end
      end
      
      describe "Scopes" do
        describe "filters by watchlist" do
          model_symbol = described_class.model_name.param_key.to_sym
          let(:record1) {create(model_symbol)}
          let(:record2) {create(model_symbol)}
          let(:record3) {create(model_symbol)}
          let(:record4) {create(model_symbol)}
          let(:user1) {create(:user)} #watches artist1
          let(:user2) {create(:user)} #watches artist2 and artist3
          let(:user3) {create(:user)} #watches artist3
          let(:user4) {create(:user)} #watches nothing
          before(:each) do
            create(:watchlist, user: user1, watched: record1)
            create(:watchlist, user: user2, watched: record2)
            create(:watchlist, user: user2, watched: record3)
            create(:watchlist, user: user3, watched: record3)
          end
          
          it "filters by watchlist" do
            expect(described_class.watched_by(user1.id)).to match_array([record1])
          end
          
          it "matches on multiple user_ids" do
            expect(described_class.watched_by([user1.id, user2.id])).to match_array([record1,record2,record3])
          end
          
          it "does not duplicate records" do
            expect(described_class.watched_by([user3.id, user2.id])).to match_array([record2,record3])        
          end
          
          it "can return nothing" do
            expect(described_class.watched_by(user4.id)).to match_array([])
          end
          
          it "returns all if nil is passed in" do
            expect(described_class.watched_by(nil)).to match_array([record1,record2,record3,record4])
          end      
          
          it "should be an active record relation" do
            expect(described_class.watched_by(user1.id).class).to_not be_a(Array)
          end
        end        
      end
      
    end
  end
end
