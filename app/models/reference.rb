class Reference < ApplicationRecord
  SiteNames = ["VGMdb", "Circus Website", "Generasia Wiki", "CDJapan", "Official Website",
               "Wikipedia", "Vocaloid Wiki", "Other Reference", "Utaite Wiki", "Touhou Wiki",
               "Vocaloid DB", "Utaite DB", "Last.fm", "Official Blog", "Twitter", "Jpopsuki",
               "Anime News Network", "VNDB", "MyAnimeList", "Youtube", "music.163.com"]

  HiddenSiteNames = ["Jpopsuki", "Youtube", "music.163.com"] #These sites could raise copyright issues, so links are kept internal.

  ReferenceLinks = [['vgmdb.net',:VGMdb], ['Last.FM',:lastpppfm], #seriously, going to sub ppp for a period
                    ['Generasia Wiki',:generasia_wiki], ['Wikipedia.org',:wikipedia],
                    ['jpopsuki.eu',:jpopsuki], ['vndb.org',:visual_novel_database],
                    ['Anime News Network', :anime_news_network],
                    ['Vocaloid wiki', :vocaloid_wiki],['Utaite wiki', :utaite_wiki],
                    ['Touhou wiki', :touhou_wiki], ['Vocaloid db', :vocaloid_DB],
                    ['Utaite db', :utaite_DB],
                    ['Circus-co.jp',:circuspppco],['Comiket Website', :comiket],
                    ['Official Website', :official],
                    ['MyAnimeList', :myAnimeList],['IMDb', :iMDb],
                    ['cdJapan', :CDJapan],
                    ['Official Blog', :official_blog],
                    ['Twitter', :twitter],
                    ['Other', :other_reference ]]

  validates :url, presence: true
  validates :model, presence: true
  validates :site_name, presence: true, inclusion: Reference::SiteNames
  validates :url, uniqueness: {scope: [:model_id, :model_type]}

  belongs_to :model, polymorphic: true

  scope :meets_security, ->(user) { where('references.site_name IN (?)', user.nil? == false && user.abilities.include?("Confident") ? SiteNames : SiteNames - HiddenSiteNames )}
end