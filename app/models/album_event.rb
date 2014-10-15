class AlbumEvent < ActiveRecord::Base
  attr_accessible :album_id, :event_id, :category

  #I don't think category actually does anything (4/19)
  
  #oh well.
  
  belongs_to :album
  belongs_to :event
end
