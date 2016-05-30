class ArtistSong < ActiveRecord::Base
  #Callbacks
    after_save :update_album

  #Associations
    belongs_to :artist
    belongs_to :song

  #Validations
    validates :artist, presence: true
    validates :song, presence: true
    validates :category, presence: true, inclusion: Array(1..(2**Artist::Credits.count - 1)).map(&:to_s)

    validates :artist_id, uniqueness: {scope: [:song_id]}


  def update_album
    unless self.song.album.nil?
      album_artist = self.song.album.artist_albums.where(artist_id: self.artist_id)
      if album_artist.empty? #If can't find one, create it
        self.song.album.artist_albums.create(:artist_id => artist.id, :category => self.category)
      else
        #Grab the categories, merge them, get uniques, add to album.
        album_artist = album_artist.first
        categories = Artist.get_credits(self.category)
        existing_categories = Artist.get_credits(album_artist.category)
        uniquecategories = (categories + existing_categories).uniq
        albumbitmask = Artist.get_bitmask(uniquecategories)
        album_artist.update_attributes(:category => albumbitmask)
      end
    end
  end
end
