class AlbumEvent < ActiveRecord::Base
  attr_accessible :album_id, :event_id, :category

  #I don't think category actually does anything (4/19)
  #oh well.
  #10/23/14 yah it totally doesn't do anything
  
  #Associations
    belongs_to :album
    belongs_to :event
    
  #Validations
    validates :album, presence: true
    validates :event, presence: true
    validates :album_id, uniqueness: {scope: :event_id}
end
