class SongSource < ActiveRecord::Base
  attr_accessible :song_id, :source_id, :classification, :op_ed_number, :ep_numbers

  #Constants
    Relationship = ['OP', 'ED', 'Insert', 'Theme Song']  
    
  #Associations
    belongs_to :song
    belongs_to :source
    
  #Validations
    validates :source, presence: true
    validates :song, presence: true
    validates :classification, presence: true, inclusion: SongSource::Relationship
    
    validates :source_id, uniqueness: {scope: [:song_id]}
  
end
