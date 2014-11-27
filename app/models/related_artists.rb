class RelatedArtists < ActiveRecord::Base
  attr_accessible :category, :artist1_id, :artist2_id

  validates :artist1_id, :presence => true, uniqueness: {scope: :artist2_id}
  validates :artist2_id, :presence => true
  validates :category, inclusion: Artist::SelfRelationships.reject {|r| r.count < 3}.map(&:last)
  validates :artist1, :presence => true
  validates :artist2, :presence => true
  validates_different_models :artist1, model: "artist"
  validates_unique_combination :artist1, model: "artist"
    
  belongs_to :artist1, class_name: "Artist", :foreign_key => :artist1_id
  belongs_to :artist2, class_name: "Artist", :foreign_key => :artist2_id
end
