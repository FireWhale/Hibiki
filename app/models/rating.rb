class Rating < ActiveRecord::Base
  #Attributes  
    attr_accessible :song_id, :user_id,
                    :rating, :favorite  
  
  #Constants
    RatingRange = Array(1..100)
  
  #Validation
    validates :song, presence: true
    validates :user, presence: true
    validates :rating, presence: true, inclusion: Rating::RatingRange
    
    validates :user_id, uniqueness: {scope: :song_id}
  
    belongs_to :song
    belongs_to :user
end
