require 'rails_helper'

module WatchlistTests
  shared_examples "it has watchlists" do |model, model_class|    
    #Associations
      it "is valid with watchers" do
        expect(build(model, :with_watcher)).to be_valid
      end 
      
      it "has many watchlists" do
        expect(create(model, :with_watcher).watchlists.first).to be_a Watchlist
        expect(model_class.reflect_on_association(:watchlists).macro).to eq(:has_many)
      end
      
      it "has many watchers" do
        expect(create(model, :with_watcher).watchers.first).to be_a User
        expect(model_class.reflect_on_association(:watchers).macro).to eq(:has_many)
      end
      
      it "destroys watchlists when destroyed" do
        record = create(model, :with_watcher)
        expect{record.destroy}.to change(Watchlist, :count).by(-1)
      end
      
      it "does not destroy users when destroyed" do
        record = create(model, :with_watcher)
        expect{record.destroy}.to change(User, :count).by(0)
      end    
      
    #Validations
      it "is valid with multiple watchlists and watchers" do
        record = create(model)
        number = Array(3..10).sample
        list = create_list(:watchlist, number, watched: record)
        expect(record.watchlists).to match_array(list)
        expect(record.watchers.count).to eq(number)
        expect(record).to be_valid
      end
      
    #Instance Methods
      it "responds to watched?" do
        expect(build(model)).to respond_to("watched?")
      end
      
      it "returns true if user is in watched?" do
        user = create(:user)
        record = create(model)
        watchlist = create(:watchlist, watched: record, user: user)
        expect(record.watched?(user)).to be true
      end
      
       it "returns false if user is not in watched?" do
        user = create(:user)
        user2 = create(:user)
        record = create(model)
        watchlist = create(:watchlist, watched: record, user: user2)
        expect(record.watched?(user)).to be false
      end     
      
    #Scopes
      it "returns a list of users who are watching this #{model.to_s}" do
        record = create(model)
        list = create_list(:watchlist, 3, watched: record)
        expect(record.watchers).to eq(list.map(&:user))
      end
    
  end
end
