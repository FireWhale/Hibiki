class Rating < ActiveRecord::Base
  attr_accessible :rating, :song_id, :user_id    
  
  validates :song, presence: true
  validates :user, presence: true
  validates :rating, presence: true, inclusion: Array(1..100)
  
  validates :user_id, uniqueness: {scope: :song_id}

  belongs_to :song
  belongs_to :user
end
