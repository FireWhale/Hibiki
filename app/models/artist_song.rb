class ArtistSong < ActiveRecord::Base
  attr_accessible :artist_id, :category, :song_id
      
  #Associations
    belongs_to :artist
    belongs_to :song
    
  #Validations
    validates :artist, presence: true
    validates :song, presence: true
    validates :category, presence: true, inclusion: Array(1..(2**Artist::Credits.count - 1))
    
    validates :artist_id, uniqueness: {scope: [:song_id]}
  
end
