require 'rails_helper'

describe Watchlist do
  include_examples "global model tests" #Global Tests
  
  it_behaves_like "it is a polymorphic join model", User, [Artist, Organization, Source], "watched"

  include_examples "is valid with or without an attribute", :position, 5
  include_examples "is valid with or without an attribute", :grouping_category, "Anime"
         
end

describe Collection do
  include_examples "global model tests" #Global Tests
  
  it_behaves_like "a join table", Album, User
  
  include_examples "is invalid without an attribute", :relationship
  include_examples "is invalid without an attribute in a category", :relationship, Collection::Relationship, "Collection::Relationship"

end

describe Rating do
  include_examples "global model tests" #Global Tests
  
  it_behaves_like "a join table", Song, User
  
  include_examples "is invalid without an attribute", :rating
  include_examples "is invalid without an attribute in a category", :rating, Rating::RatingRange, "Rating::RatingRange"
  include_examples "is valid with or without an attribute", :favorite, "Complete"

end

describe IssueUser do
  include_examples "global model tests" #Global Tests
  
  it_behaves_like "a join table", Issue, User
  
  include_examples "is valid with or without an attribute", :comment, "hi"
  include_examples "is valid with or without an attribute", :vote, "this be a vote"
  
  it "should be valid with an issue, comment, vote and user" do
    expect(build(:issue_user)).to be_valid
  end
  
  it "is invalid if it doesn't have a comment or vote" do
    expect(build(:issue_user, comment: "", vote: "")).to_not be_valid
  end

  it "points to a shell user called 'deleted user' if user is destroyed"
end


