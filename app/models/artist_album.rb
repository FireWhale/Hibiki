class ArtistAlbum < ActiveRecord::Base
  attr_accessible :album_id, :artist_id, :category  
  
  belongs_to :album
  belongs_to :artist
  
end
