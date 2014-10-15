class SourceSeason < ActiveRecord::Base
  attr_accessible :category, :season_id, :source_id
  
  Categories = [["Airing"],["Previous Season Leftover"],
  ["Movie"],["OVA/ONA/Special"],["Short"]]
  
  belongs_to :season
  belongs_to :source
end
