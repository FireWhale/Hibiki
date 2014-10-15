class SongSource < ActiveRecord::Base
  attr_accessible :song_id, :source_id, :classification, :op_ed_number, :ep_numbers
  
  belongs_to :song
  belongs_to :source
  
  Relationship = ['OP', 'ED', 'Insert', 'Theme Song']  
end
