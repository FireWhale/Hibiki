class RelatedArtists < ActiveRecord::Base
  attr_accessible :category, :artist1_id, :artist2_id
  
  belongs_to :artist1, class_name: "Artist", :foreign_key => :artist1_id
  belongs_to :artist2, class_name: "Artist", :foreign_key => :artist2_id
end
