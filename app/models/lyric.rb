class Lyric < ActiveRecord::Base
  #Attributes 
    attr_accessible :language, :song_id, :lyrics
  
  #Modules

  #Cateogires
    #Languages are set in the User model
    
  #Validation
    validates :language, presence: true, inclusion: User::Languages.split(","), uniqueness: {scope: :song_id}
    validates :song, presence: true
    validates :lyrics, presence: true
  
  #Associations
    belongs_to :song
         
  #Scopes
    
  #Gem Stuff

  

end
