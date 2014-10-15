class RelatedAlbums < ActiveRecord::Base
  attr_accessible :category, :album1_id, :album2_id
  
  belongs_to :album1, class_name: "Album", :foreign_key => :album1_id
  belongs_to :album2, class_name: "Album", :foreign_key => :album2_id
end
