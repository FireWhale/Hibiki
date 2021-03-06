class AlbumSource < ApplicationRecord

  include NeoRelModule

  #Associations
    belongs_to :album
    belongs_to :source
    
  #Validations
    validates :album, presence: true
    validates :source, presence: true

    validates :album_id, uniqueness: {scope: [:source_id]}

  def neo_relation
    neo_rel(album,source)
  end

end
