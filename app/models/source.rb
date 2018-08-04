class Source < ApplicationRecord

  #Modules
    include AssociationModule
    include SolrSearchModule
    include LanguageModule
    include JsonModule
    include DateModule
    include NeoNodeModule
    #Association Modules
      include SelfRelationModule
      include ImageModule
      include PostModule
      include LogModule
      include TagModule
      include ReferenceModule
      include WatchlistModule

  #Attributes
    serialize :namehash

    attr_accessor :new_organizations
    attr_accessor :update_source_organizations
    attr_accessor :remove_source_organizations

  #Callbacks/Hooks
    after_save :manage_organizations

  #Constants
    Activity = ["Complete", "Ongoing", "Not Yet Aired"]
    Categories = ["Franchise","Product"]
    SelfRelationships = [['is a prequel of', 'Sequel', 'Prequel', 'Prequel'],
    ['is a sequel of', '-Prequel'], #aka sequel
    ['is adapted as', 'Adpated As', 'An Adaption Of', 'Adaptation'],
    ['is an adaptation of', '-Adaptation'],
    ['has the same setting as', 'Same Setting', 'Same Setting', 'Same Setting'], #order doesn't matter
    ['shares characters with', 'Shares Characters', 'Shares Characters', 'Shares Characters'], #order doesn't matter
    ['is the parent story of', 'Side Story', 'Parent Story', 'Parent Story'],
    ['has the fandisc', '-Fan Disc'],
    ['is a fandisc of', 'Original Story', 'Fan Disc', 'Fan Disc'],
    ['\'s franchise includes', 'Franchise Includes', 'Part of Franchise', 'Franchise'],
    ['is part of the franchise', '-Franchise'],
    ['is a side story of', '-Parent Story'], #aka Side Story
    ['is in the same series as', 'Same Series', 'Same Series', 'Same Series'], #order doesn't matter
    ['is an alternate version of', 'Alternate Version', 'Alternate Version', 'Alternate Version'],
    ['is in an alternate setting of', 'Alternate Setting', 'Alternate Setting', 'Alternate Setting']] #order doesn't matter

    FormFields = [{type: "markup", tag_name: "div class='col-md-6'"},
                  {type: "text", attribute: :internal_name, label: "Internal Name:"},
                  {type: "text", attribute: :synonyms, label: "Synonyms:"},
                  {type: "language_fields", attribute: :name},
                  {type: "select", attribute: :status, label: "Status:", categories: Album::Status},
                  {type: "select", attribute: :db_status, label: "Database Status:", categories: Artist::DatabaseStatus},
                  {type: "select", attribute: :category, label: "Categories:", categories: Source::Categories},
                  {type: "select", attribute: :activity, label: "Activity:", categories: Source::Activity},
                  {type: "references"},
                  {type: "date", attribute: :release_date, label: "Release Date:"},
                  {type: "date", attribute: :end_date, label: "End Date:"},
                  {type: "images"},
                  {type: "tags", div_class: "well", title: "Tags"},
                  {type: "language_fields", attribute: :info},
                  {type: "text_area", attribute: :info, rows: 4, label: "Info:"},
                  {type: "text_area", attribute: :synopsis, rows: 2, label: "Synopsis:"},
                  {type: "text_area", attribute: :plot_summary, rows: 4, label: "Plot Summary:"},
                  {type: "markup", tag_name: "/div"}, {type: "markup", tag_name: "div  class='col-md-6'"},
                  {type: "self_relations", div_class: "well", title: "Source Relationships", sub_div_id: "Sources"},
                  {type: "related_model", div_class: "well", title: "Organization Relationships", model: "organization", relation_model: "source_organizations", categories: SourceOrganization::Categories, sub_div_id: "Organizations"},
                  {type: "namehash", title: "Languages", div_class: "well", sub_div_id: "Languages"},
                  {type: "text_area", attribute: :private_info, rows: 10, label: "Private Info:"},
                  {type: "markup", tag_name: "/div"}]

  #Validation
    validates :internal_name, presence: true
    validates :status, presence: true, inclusion: Album::Status
    validates :db_status, inclusion: Artist::DatabaseStatus, allow_nil: true, allow_blank: true
    validates :activity, inclusion: Source::Activity, allow_nil: true, allow_blank: true
    validates :category, inclusion: Source::Categories, allow_nil: true, allow_blank: true

  #Associations
    #Primary Aassociations
      has_many :album_sources, dependent: :destroy
      has_many :albums, through: :album_sources

      has_many :source_organizations, dependent: :destroy
      has_many :organizations, through: :source_organizations

      has_many :song_sources, dependent: :destroy
      has_many :songs, through: :song_sources

    #Secondary Associations
      has_many :source_seasons, dependent: :destroy
      has_many :seasons, through: :source_seasons

  #Scopes
    scope :with_category, ->(categories) { where('category IN (?)', categories)}
    scope :with_status, ->(statuses) {where('status IN (?)', statuses)}
    scope :with_activity, ->(activities) {where('activity IN (?)', activities)}
    scope :in_date_range, ->(start_date, end_date) {where("sources.release_date >= ? and sources.release_date <= ? ", start_date, end_date)}

  #Gem Stuff
    #Pagination
      paginates_per 50

  private
    def manage_organizations
      self.manage_primary_relation(Organization,SourceOrganization)
    end
end
