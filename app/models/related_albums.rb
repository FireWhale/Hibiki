class RelatedAlbums < ActiveRecord::Base
  attr_accessible :category, :album1_id, :album2_id
 
  validates :album1_id, :presence => true, uniqueness: {scope: :album2_id}
  validates :album2_id, :presence => true
  validates :category, inclusion: Album::SelfRelationships.map { |relation| relation[3]}.reject(&:nil?)
  validates :album1, :presence => true
  validates :album2, :presence => true
  validates_different_models :album1, model: "album"
  validates_unique_combination :album1, model: "album"  
  
  belongs_to :album1, class_name: "Album", :foreign_key => :album1_id
  belongs_to :album2, class_name: "Album", :foreign_key => :album2_id
  
end