class RelatedSongs < ActiveRecord::Base
  attr_accessible :category, :song1_id, :song2_id

  validates :song1_id, :presence => true, uniqueness: {scope: :song2_id}
  validates :song2_id, :presence => true
  validates :category, inclusion: Song::SelfRelationships.map { |relation| relation[3]}.reject(&:nil?)
  validates :song1, :presence => true
  validates :song2, :presence => true
  validates_different_models :song1, model: "song"
  validates_unique_combination :song1, model: "song"
  
  belongs_to :song1, class_name: "Song", :foreign_key => :song1_id
  belongs_to :song2, class_name: "Song", :foreign_key => :song2_id
  
  
  
  def song_ids
    [song1_id] + [song2_id]
  end
  
  def recursive_grabber(list)
    #First I check to see if the relation I'm using is included
    unless list[:relation_ids].include?(self.id)
      #If it's not in the list (aka unless), I add it to the list and continue
      (list[:relation_ids] ||= []) << self.id
      #If the relation is "Same Song", I treat the songs as the same as the original.
      if self.category == "Same Song"
        #Do the full recursive
        
      elsif self.category == "Arrangement" || self.category == "Alternate Version"
        #If it isn't, we still care about the relationship, we just don't extend further.
        #
      end
      #I then grab their songs
      
      
      self.song_ids.each do |song_id|
        #I am already iterating over all the songs already contained in list
        #Therefore, I check that the song isn't in the list
        unless list[:song_ids].include?(song_id)
          #If it isn't, I add it to the list and grab all the related songs
          (list[:song_ids] ||= []) << song_id
          #While I could load the song and call related_song_relations on it to find
          #the relations I'm looking for, I am going to reduce a query and directly 
          #call the relations, without loading the song. 
          (RelatedSongs.where(:song1_id => song_id) + RelatedSongs.where(:song2_id => song_id)).each do |relation|
            relation.recursive_grabber(list)
          end
        end
      end
    end
  end
  
end
