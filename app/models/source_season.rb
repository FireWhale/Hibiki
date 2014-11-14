class SourceSeason < ActiveRecord::Base
  attr_accessible :category, :season_id, :source_id
  
  Categories = ["Airing","Previous Season Leftover",
  "Movie","OVA/ONA/Special","Short"]
  #Associations
    belongs_to :season
    belongs_to :source
  
  #Validations
    validates :source, presence: true
    validates :season, presence: true
    validates :category, inclusion: SourceSeason::Categories
    validates :source_id, uniqueness: {scope: :season_id}
end