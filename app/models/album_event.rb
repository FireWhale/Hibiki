class AlbumEvent < ApplicationRecord

  include NeoRelModule

  #Associations
    belongs_to :album
    belongs_to :event
    
  #Validations
    validates :album, presence: true
    validates :event, presence: true
    validates :album_id, uniqueness: {scope: :event_id}

  def neo_relation
    neo_rel(album,event)
  end

end