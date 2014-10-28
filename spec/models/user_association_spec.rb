require 'rails_helper'

shared_examples "a user relation" do |relation, model|
  #Gut check
    it "has a valid factory" do
      expect(create(relation)).to be_valid
    end   
  
  #Association Tests
    it "should have a user" do
      #2 tests
      expect(build(relation).user).to be_a User
      expect(model.reflect_on_association(:user).macro).to eq(:belongs_to)
    end
    
  #Validation tests
    it "is invalid without a user" do
      expect(build(relation, user: nil)).to_not be_valid
    end
    
    it "is invalid with a user that does not exist" do
      expect(build(relation, user_id: 99999999)).to_not be_valid
    end
end

describe Watchlist do
  #Shared Examples
    it_behaves_like "a user relation", :watchlist, Watchlist
  
  #Association Test
    it "should have a watched polymorphic relationship" do
      expect(Watchlist.reflect_on_association(:watched).macro).to eq(:belongs_to)
    end
    
  #Validation
    it "is valid with an artist" do
      expect(build(:watchlist, :with_artist)).to be_valid
    end
    
    it "is valid with a source" do
      expect(build(:watchlist, :with_source)).to be_valid
    end

    it "is valid with an organization" do
      expect(build(:watchlist, :with_organization)).to be_valid
    end
    
    it "is invalid with a song" do
      expect(build(:watchlist, :with_song)).to_not be_valid      
    end
    
    it "is invalid with a watched_type of 'Hi'" 
  
    it "is invalid without a watched_type" do
      expect(build(:watchlist, :with_artist, watched_type: nil)).to_not be_valid
    end
    
    it "is valid with a status, position, and grouping_category" do
      expect(build(:watchlist, status: "Complete", position: 5, grouping_category: "Anime")).to be_valid
    end
    
    it "is invalid without a watched that is in the database"  do
      expect(build(:watchlist, watched_type: "Artist", watched_id: 99999999)).to_not be_valid
    end
    
    it "should have a unique watched/user combination" do
      @artist = create(:artist)
      @user = create(:user)
      expect(create(:watchlist, watched: @artist, user: @user)).to be_valid
      expect(build(:watchlist, watched: @artist, user: @user)).to_not be_valid
    end
end

describe Collection do
  #Shared Examples
    it_behaves_like "a user relation", :collection, Collection
  
  #Association Tests
    it "should have an album" do
      expect(build(:collection).album).to be_a Album
    end
    
    it "should have an album test 2" do
      expect(Collection.reflect_on_association(:album).macro).to eq(:belongs_to)
    end
    
  #Validation
    it "should be valid with an album, user, and relationship" do
      expect(build(:collection)).to be_valid
    end
    
    it "is invalid without an album" do
      expect(build(:collection, album_id: nil)).to_not be_valid
    end
    
    it "is invalid without a real album" do
      expect(build(:collection, album_id: 99999999)).to_not be_valid
    end
    
    it "is invalid without a relationship" do
      expect(build(:collection, relationship: nil)).not_to be_valid
    end
    
    it "is invalid with a relationship not in the relationships list" do
      expect(build(:collection, relationship: "hoho")).not_to be_valid
    end
    
    it "is invalid when there's a duplicate user/album combinations" do
      @album = create(:album)
      @user = create(:user)
      expect(create(:collection, user: @user, album: @album)).to be_valid
      expect(build(:collection, user: @user, album: @album)).to_not be_valid
    end
end

describe Rating do
  #Shared Examples
    it_behaves_like "a user relation", :rating, Rating

  #Association Tests
    it "should have a song" do
      expect(build(:rating).song).to be_a Song
    end
    
    it "should have a song test 2" do
      expect(Rating.reflect_on_association(:song).macro).to eq(:belongs_to)
    end
    
  #Validation
    it "is valid with a song, rating and user" do
      expect(build(:rating)).to be_valid
    end
    
    it "is invalid without a song" do
      expect(build(:rating, song_id: nil)).to_not be_valid
    end
    
    it "is invalid without a real song" do
      expect(build(:rating, song_id: 99999999)).to_not be_valid
    end

    it "is invalid without a rating" do
      expect(build(:rating, rating: nil)).to_not be_valid
    end
    
    it "is invalid without a rating in the rating range" do
      expect(build(:rating, rating: 99999999)).to_not be_valid
    end
    
    it "is valid with a favorite" do
      expect(build(:rating, favorite: "yes")).to be_valid
    end
    
    it "is invalid when there's a duplicate user/song combinations" do
      @user = create(:user)
      @song = create(:song)
      expect(create(:rating, song: @song, user: @user)).to be_valid
      expect(build(:rating, song: @song, user: @user)).to_not be_valid
    end
end

describe IssueUser do
  #Shared Examples
    it_behaves_like "a user relation", :issue_user, IssueUser

  #Association Tests
    it "should have an issue" do
      expect(build(:issue_user).issue).to be_a Issue
    end
    
    it "should have an issue test 2" do
      expect(IssueUser.reflect_on_association(:issue).macro).to eq(:belongs_to)
    end
    
  #Validation
    it "should be valid with an issue, comment, vote and user" do
      expect(build(:issue_user)).to be_valid
    end
    
    it "is invalid without an issue" do
      expect(build(:issue_user, issue_id: nil)).to_not be_valid
    end
    
    it "is invalid without a real issue" do
      expect(build(:issue_user, issue_id: 99999999)).to_not be_valid
    end

    it "is valid with an empty comment" do
      expect(build(:issue_user, comment: "")).to be_valid
    end
    
    it "is valid without a vote" do
      expect(build(:issue_user, vote: "")).to be_valid      
    end
    
    it "is invalid if it doesn't have a comment or vote" do
      expect(build(:issue_user, comment: "", vote: "")).to_not be_valid
    end
    
    it "is valid when there's a duplicate user/song combinations" do
      instance = create(:issue_user)
      expect(build(:issue_user)).to be_valid
    end      
end


