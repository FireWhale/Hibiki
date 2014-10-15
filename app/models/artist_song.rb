class ArtistSong < ActiveRecord::Base
  attr_accessible :artist_id, :category, :song_id

  belongs_to :artist
  belongs_to :song
end
