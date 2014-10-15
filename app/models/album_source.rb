class AlbumSource < ActiveRecord::Base
  attr_accessible :album_id, :source_id
  
  belongs_to :album
  belongs_to :source
end
