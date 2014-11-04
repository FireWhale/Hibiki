require 'rails_helper'

shared_examples "a user relation" do |relation, model|
  #Gut check
    it "has a valid factory" do
      expect(create(relation)).to be_valid
    end   
  
  #Association Tests
    it "belongs to a user" do
      #2 tests
      expect(build(relation).user).to be_a User
      expect(model.reflect_on_association(:user).macro).to eq(:belongs_to)
    end
    
    it "does not destroy the user when destroyed" do
      record = create(relation)
      expect{record.destroy}.to change(User, :count).by(0)
    end
    
  #Validation tests
    it "is valid with a user" do
      user = create(:user)
      expect(build(relation, user: user)).to be_valid
    end
  
    it "is invalid without a user" do
      expect(build(relation, user: nil)).to_not be_valid
    end
    
    it "is invalid without a real user" do
      expect(build(relation, user_id: 99999999)).to_not be_valid
    end
end

describe Watchlist do
  #Shared Examples
    it_behaves_like "a user relation", :watchlist, Watchlist
  
  #Association Test
    it "belongs to a watched" do
      expect(Watchlist.reflect_on_association(:watched).macro).to eq(:belongs_to)
    end

    it "does not destroy the watched when destroyed" do
      watchlist = create(:watchlist)
      expect{watchlist.destroy}.to change(Artist, :count).by(0)
    end
    
  #Validation
    it_behaves_like "it is a polymorphic join model", :watchlist, "user", "watched", "artist", ["artist", "organization", "source"]

    it "is invalid with a song" do
      song = create(:song)
      expect(build(:watchlist, watched: song)).to_not be_valid      
    end
      
    include_examples "is valid with or without an attribute", :watchlist, :status, "Complete"
    include_examples "is valid with or without an attribute", :watchlist, :position, 5
    include_examples "is valid with or without an attribute", :watchlist, :grouping_category, "Anime"
         
end

describe Collection do
  #Shared Examples
    it_behaves_like "a user relation", :collection, Collection
  
  #Association Tests
    it "does not destroy the album when destroyed" do
      collection = create(:collection)
      expect{collection.destroy}.to change(Album, :count).by(0)
    end   
         
  #Validation
    it_behaves_like "a join table", :collection, "album", "user", Collection
    
    include_examples "is invalid without an attribute", :collection, :relationship
    include_examples "is invalid without an attribute in a category", :collection, :relationship, Collection::Relationship, "Collection::Relationship"

end

describe Rating do
  #Shared Examples
    it_behaves_like "a user relation", :rating, Rating

  #Association Tests
    it "does not destroy the song when destroyed" do
      rating = create(:rating)
      expect{rating.destroy}.to change(Song, :count).by(0)
    end 
         
  #Validation
    it_behaves_like "a join table", :rating, "song", "user", Rating
    
    include_examples "is invalid without an attribute", :rating, :rating
    include_examples "is invalid without an attribute in a category", :rating, :rating, Rating::RatingRange, "Rating::RatingRange"
    
    include_examples "is valid with or without an attribute", :rating, :favorite, "Complete"

end

describe IssueUser do
  #Shared Examples
    it_behaves_like "a user relation", :issue_user, IssueUser

  #Association Tests    
    it "belongs to an Issue" do
      expect(build(:issue_user).issue).to be_a Issue
      expect(IssueUser.reflect_on_association(:issue).macro).to eq(:belongs_to)
    end
    
    it "does not destroy issues when destroyed" do
      issueuser = create(:issue_user)
      expect{issueuser.destroy}.to change(Issue, :count).by(0)
    end
    
  #Validation
    include_examples "is valid with or without an attribute", :issue_user, :comment, "hi"
    include_examples "is valid with or without an attribute", :issue_user, :vote, "this be a vote"
    
    it "should be valid with an issue, comment, vote and user" do
      expect(build(:issue_user)).to be_valid
    end
    
    it "is invalid without an issue" do
      expect(build(:issue_user, issue_id: nil)).to_not be_valid
    end
    
    it "is invalid without a real issue" do
      expect(build(:issue_user, issue_id: 99999999)).to_not be_valid
    end
    
    it "is invalid if it doesn't have a comment or vote" do
      expect(build(:issue_user, comment: "", vote: "")).to_not be_valid
    end
    
    it "is valid when there's a duplicate user/song combinations" do
      issue = create(:issue)
      user = create(:user)
      expect(create(:issue_user, issue: issue, user: user)).to be_valid
      expect(build(:issue_user, issue: issue, user: user)).to be_valid
    end      

  #Callbacks
    it "points to a shell user called 'deleted user' if user is destroyed"
end


