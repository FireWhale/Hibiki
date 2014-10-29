class ArtistAlbum < ActiveRecord::Base
  attr_accessible :album_id, :artist_id, :category  
  #Associations
    belongs_to :artist
    belongs_to :album
    
  #Validations
    validates :artist, presence: true
    validates :album, presence: true
    validates :category, presence: true, inclusion: Array(1..(2**Artist::Credits.count - 1))
    
  
end
