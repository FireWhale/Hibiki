class Album < ApplicationRecord

  #Modules
    include AssociationModule
    include SolrSearchModule
    include LanguageModule
    include JsonModule
    include DateModule
    #Association Modules
      include SelfRelationModule
      include ImageModule
      include PostModule
      include LogModule
      include TagModule
      include ReferenceModule
      include CollectionModule

  #Attributes
    serialize :namehash

    attr_accessor :new_events
    attr_accessor :new_events_by_name
    attr_accessor :remove_album_events

    attr_accessor :new_artists
    attr_accessor :update_artist_albums

    attr_accessor :new_organizations
    attr_accessor :new_organizations_by_name
    attr_accessor :update_album_organizations
    attr_accessor :remove_album_organizations

    attr_accessor :new_sources
    attr_accessor :new_sources_by_name
    attr_accessor :remove_album_sources

    attr_accessor :new_songs

  #Callbacks/Hooks
    after_save :manage_events
    after_save :manage_organizations
    after_save :manage_artists
    after_save :manage_sources
    after_save :manage_songs

  #Multiple Model Constants - Put here for lack of a better place
    Status = ['Released', 'Unreleased', 'Hidden', 'Private']
      #Hidden - Just a placeholder in the database - maaya => maaya sakamoto
      #Private - Things that are out of scope of the database but I still like

  #Model Constants
    SelfRelationships = [['is a limited edition of', "Normal Versions", "Limited Editions", 'Limited Edition'],
    ['has the limited edition', '-Limited Edition'],
    ['is a reprint of', "Reprinted From", "Reprints", 'Reprint'],
    ['has the reprint', '-Reprint'],
    ['is an alternate printing of', "Alternate Printings", "Alternate Printings", 'Alternate Printing'], #Alternate printings = same songs
    ['has the alternate printing', '-Alternate Printing'],
    ['is in the same collection as', "Same Series", "Same Series", 'Collection'],
    ['is an alternate version of', "Alternate Printings", "Alternate Printings", 'Alternate Version'], #Alt versions = slightly different songs
    ['is an instrumental version of', "Normal Versions", "Instrumental Versions", 'Instrumental'],
    ['has the instrumental version', '-Instrumental']]

    FormFields = [{type: "markup", tag_name: "div class='col-md-6'"},
                  {type: "text", attribute: :internal_name, label: "Internal Name:"},
                  {type: "text", attribute: :synonyms, label: "Synonyms:"},
                  {type: "language_fields", attribute: :name},
                  {type: "text", attribute: :catalog_number, label: "Catalog Number:"},
                  {type: "date", attribute: :release_date, label: "Release Date:"},
                  {type: "select", attribute: :status, label: "Status:", categories: Album::Status},
                  {type: "text", attribute: :classification, label: "Classification:"},
                  {type: "references"}, {type: "events"}, {type: "images"},
                  {type: "tags", div_class: "well", title: "Tags"},
                  {type: "language_fields", attribute: :info},
                  {type: "text_area", attribute: :info, rows: 4, label: "Info:"},
                  {type: "text_area", attribute: :private_info, rows: 10, label: "Private Info:"},
                  {type: "markup", tag_name: "/div"}, {type: "markup", tag_name: "div  class='col-md-6'"},
                  {type: "self_relations", div_class: "well", title: "Album Relationships", sub_div_id: "Albums"},
                  {type: "artist_relations", div_class: "well", title: "Artist Relationships", sub_div_id: "Artists"} ,
                  {type: "related_model", div_class: "well", title: "Source Relationships", model: "source", relation_model: "album_sources", sub_div_id: "Sources"},
                  {type: "related_model", div_class: "well", title: "Organization Relationships", model: "organization", relation_model: "album_organizations", categories: AlbumOrganization::Categories, sub_div_id: "Organizations"},
                  {type: "namehash", title: "Languages", div_class: "well", sub_div_id: "Languages"}, {type: "songs", title: "Songs", div_class: "well", sub_div_id: "Songs"},
                  {type: "markup", tag_name: "/div"}]

    #Artistreplace is used to replace names with IDs when adding artists by name to an album.
    #Since adding by name only applies to scrapes, we need a way to differeniate artists
    #with the same name. This will give a "default" ID to use, as well as keep track of
    #artists with the same name.
    Artistreplace = [
      ['SHIHO', 39004 ], #2 artists. I've Sound SHIHO (39004) in favor of Stereopony SHIHO(3221)
      ['96', 39007 ], #2 artists. IOSYS guitarist (39007) in favor of guitarfreak's 96 (868))
      ['AKINO', 432 ], #2 artists. bless4 singer (432) in favor of 2nd Flush arranger (39017))
      ['Takashi', 4326 ], #3 artists. all pretty defunct. macado (3932), Birth Entertainment (4326), and touhouist (39019)
      ['void', 225 ], #IOSYS arranger (225) in favor of Divere Systems/Trance void (39102)
      ['Lily', 1901 ], #real life partner of morrigan (1901) in favor of vocaloid (41078)
      ['JIN', 1434 ], #Vocaloid producer over Musician and Beatmania Singer
      ['Peco', 5927], #Liz Triangle artist over some 1997 ost artist
    ]

    #Ignore Artist Names - for ignoring certain names when scraping, particulary organizations in parenthesis
    IgnoredArtistNames = [")", "()", "(", '(Elements Garden)', '(Angel Note)', "(CROW'SCLAW)", '(C9)', '?']

  #Validation
    validates :internal_name, presence: true
    validates :status, presence: true
    validates :catalog_number, presence: true, uniqueness: {scope: [:internal_name, :release_date]}


  #associations
    #Primary Associations
      has_many :album_sources
      has_many :sources, through: :album_sources, dependent: :destroy

      has_many :artist_albums
      has_many :artists, through: :artist_albums, dependent: :destroy

      has_many :album_organizations
      has_many :organizations, through: :album_organizations, dependent: :destroy

      has_many :songs, dependent: :destroy

    #Secondary Associations
      has_many :album_events
      has_many :events, through: :album_events, dependent: :destroy

  #Scopes
    scope :with_status, ->(statuses) {where('status IN (?)', statuses)}
    scope :in_date_range, ->(start_date, end_date) {where("albums.release_date >= ? and albums.release_date <= ? ", start_date, end_date)}

    #These following three scopes are necessary because with_aos handles nil differently
    scope :with_artist, ->(artist_ids) {joins(:artist_albums).where('artist_albums.artist_id IN (?)', artist_ids).uniq unless artist_ids.nil?}
    scope :with_source, ->(source_ids) {joins(:album_sources).where('album_sources.source_id IN (?)', source_ids).uniq unless source_ids.nil?}
    scope :with_organization, ->(organization_ids) {joins(:album_organizations).where('album_organizations.organization_id IN (?)', organization_ids).uniq unless organization_ids.nil?}
    scope :with_artist_organization_source, ->(artist_ids, organization_ids, source_ids) {from("((#{Album.joins(:artist_albums).where("artist_albums.artist_id IN (?)", artist_ids).to_sql})
                                                                             union (#{Album.joins(:album_sources).where('album_sources.source_id IN (?)', source_ids).to_sql})
                                                                             union (#{Album.joins(:album_organizations).where('album_organizations.organization_id IN (?)', organization_ids).to_sql})) #{Album.table_name} ").references(:artist_albums, :album_sources, :album_organizations) unless artist_ids.nil? && organization_ids.nil? && source_ids.nil?}

    #User Settings
    scope :filter_by_user_settings, ->(user) {not_in_collection(user.id, user.album_filter).without_self_relation_categories(user.album_filter) unless user.nil?}

  #Gem Stuff
    #Pagination
    paginates_per 50

  #For sorting albums
    def week(start_day = "sunday") #For sorting by week
      self.release_date? ? self.release_date.beginning_of_week(start_day.to_sym) : nil
    end

    def month #For sorting by month
      self.release_date? ? self.release_date.beginning_of_month : nil
    end

    def year
      self.release_date? ? self.release_date.beginning_of_year : nil
    end


  #Limited Edition and reprint check
    def limited_edition?
      self.related_album_relations1.map(&:category).include?("Limited Edition")
    end

    def reprint?
      self.related_album_relations1.map(&:category).include?("Reprint")
    end

    def alternate_printing?
      self.related_album_relations1.map(&:category).include?("Alternate Printing")
    end

  private
    def manage_events
      self.manage_primary_relation(Event,AlbumEvent)
    end

    def manage_artists
      self.manage_artist_relation
    end

    def manage_sources
      self.manage_primary_relation(Source,AlbumSource)
    end

    def manage_organizations
      self.manage_primary_relation(Organization,AlbumOrganization)
    end

    def manage_songs
      #Update - Not implemented since this is for updating the relationship. Not the song itself.
      #         There is no categorization of the relationship between songs and albums (they always just belong to an album)
      #Destroy - Not implemented at this time. Manually delete songs.

      #Create
      new_song_values = ActiveSupport::HashWithIndifferentAccess.new(self.new_songs)
      unless new_song_values.blank?
       new_song_values.values.transpose.each do |info|
          attributes = [new_song_values.keys,info].transpose.to_h
          self.songs.create(attributes)
        end
      end
    end



end