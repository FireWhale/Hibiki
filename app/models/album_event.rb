class AlbumEvent < ApplicationRecord

  include NeoRelModule
  after_save :neo_update

  #Associations
    belongs_to :album
    belongs_to :event
    
  #Validations
    validates :album, presence: true
    validates :event, presence: true
    validates :album_id, uniqueness: {scope: :event_id}

  def neo_update
    neo_rel(album,event)
  end

end