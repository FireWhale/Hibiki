class Reference < ActiveRecord::Base
  attr_accessible :url, :site_name
  
  SiteNames = ["VGMdb", "Circus Website", "Generasia Wiki", "CDJapan", "Official Website", 
               "Wikipedia", "Vocaloid Wiki", "Other Reference", "Utaite Wiki", "Touhou Wiki", 
               "Vocaloid DB", "Utaite DB", "Last.fm", "Official Blog", "Twitter", "Jpopsuki", 
               "Anime News Network", "VNDB", "MyAnimeList", "Youtube", "music.163.com"]
               
  HiddenSiteNames = ["Jpopsuki", "Youtube", "music.163.com"] #These sites could raise copyright issues, so links are kept internal.
  
  validates :url, presence: true
  validates :model, presence: true
  validates :site_name, presence: true, inclusion: Reference::SiteNames
  validates :site_name, uniqueness: {scope: [:model_id, :model_type]}

  belongs_to :model, polymorphic: true
  
  scope :meets_security, ->(user) { where('references.site_name IN (?)', user.nil? == false && user.abilities.include?("Confident") ? SiteNames : SiteNames - HiddenSiteNames )}
end
