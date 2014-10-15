class Rating < ActiveRecord::Base
  attr_accessible :rating, :song_id, :user_id    
  
  belongs_to :song
  belongs_to :user
end
