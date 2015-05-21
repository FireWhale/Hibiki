require 'rails_helper'

describe Watchlist do
  include_examples "global model tests" #Global Tests
    
  it_behaves_like "it is a polymorphic join model", User, [Artist, Organization, Source], "watched"

  include_examples "is valid with or without an attribute", :position, 5
  include_examples "is valid with or without an attribute", :grouping_category, "Anime"
         
end

describe Collection do
  include_examples "global model tests" #Global Tests
    
  it_behaves_like "it is a polymorphic join model", User, [Album, Song], "collected"
  
  include_examples "is invalid without an attribute", :relationship
  include_examples "is invalid without an attribute in a category", :relationship, Collection::Relationship, "Collection::Relationship"
  include_examples "is valid with or without an attribute", :user_comment, "Anime"
  include_examples "is valid with or without an attribute", :rating, 5

  include_examples "it has a partial date", :date_obtained

  
end
