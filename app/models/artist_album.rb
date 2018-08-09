class ArtistAlbum < ApplicationRecord

  #Modules
    include LanguageModule
    include NeoRelModule

  #Associations
    belongs_to :artist
    belongs_to :album

  #Validations
    validates :artist, presence: true
    validates :album, presence: true
    validates :category, presence: true, inclusion: Array(1..(2**Artist::Credits.count - 1)).map(&:to_s)

    validates :artist_id, uniqueness: {scope: [:album_id]}

    def neo_relation
      neo_rel(artist,album)
    end

end
