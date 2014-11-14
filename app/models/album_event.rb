class AlbumEvent < ActiveRecord::Base
  attr_accessible :album_id, :event_id
  
  #Associations
    belongs_to :album
    belongs_to :event
    
  #Validations
    validates :album, presence: true
    validates :event, presence: true
    validates :album_id, uniqueness: {scope: :event_id}
end