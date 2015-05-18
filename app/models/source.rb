class Source < ActiveRecord::Base
  #Attributes
    attr_accessible :internal_name, :synonyms, :namehash, #Names!
                    :status, :db_status, :category, :activity, #Database Stuff!
                    :reference, :info, :private_info, :synopsis, :plot_summary, #Text Info!
                    :release_date, :end_date, #Dates!
                    :popularity #Not yet implemented

    attr_accessor   :album_count
    
    serialize :reference
    serialize :namehash
    
  #Modules
    include FullUpdateModule
    include SolrSearchModule
    include AutocompleteModule
    include LanguageModule
    #Association Modules
      include SelfRelationModule
      include ImageModule
      include PostModule
      include TagModule
      include WatchlistModule

  #Callbacks/Hooks
    before_validation :convert_names
    
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
    ['\'s franchise includes', 'Franchise Includes', 'Part of Franchie', 'Franchise'],
    ['is part of the franchise', '-Franchise'],
    ['is a side story of', '-Parent Story'], #aka Side Story
    ['is in the same series as', 'Same Series', 'Same Series', 'Same Series'], #order doesn't matter
    ['is an alternate version of', 'Alternate Version', 'Alternate Version', 'Alternate Version'],
    ['is in an alternate setting of', 'Alternate Setting', 'Alternate Setting', 'Alternate Setting']] #order doesn't matter
  
    FullUpdateFields = {reference: true, seasons: true,
                        relations_by_id: {organization: [:new_organization_ids, :new_organization_categories, :update_source_organizations, :remove_source_organizations, SourceOrganization, "source_organizations"]},
                        self_relations: [:new_related_source_ids, :new_related_source_categories, :update_related_sources, :remove_related_sources],
                        images: ["id", "sourceimages/", "Primary"], 
                        dates: ["release_date", "end_date"]}

    FormFields = [{type: "markup", tag_name: "div class='col-md-6'"},
                  {type: "text", attribute: :internal_name, label: "Internal Name:"},
                  {type: "text", attribute: :synonyms, label: "Synonyms:"},
                  {type: "select", attribute: :status, label: "Status:", categories: Album::Status},
                  {type: "select", attribute: :db_status, label: "Database Status:", categories: Artist::DatabaseStatus},
                  {type: "select", attribute: :category, label: "Categories:", categories: Source::Categories},
                  {type: "select", attribute: :activity, label: "Activity:", categories: Source::Activity},
                  {type: "references"},
                  {type: "date", attribute: :release_date, label: "Release Date:"}, 
                  {type: "date", attribute: :end_date, label: "End Date:"}, 
                  {type: "images"},
                  {type: "tags", div_class: "well", title: "Tags"},
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
    validates :internal_name, presence: true , uniqueness: {scope: [:reference]}
    validates :status, presence: true, inclusion: Album::Status
    validates :db_status, inclusion: Artist::DatabaseStatus, allow_nil: true, allow_blank: true
    validates :activity, inclusion: Source::Activity, allow_nil: true, allow_blank: true
    validates :category, inclusion: Source::Categories, allow_nil: true, allow_blank: true
    validates :release_date, presence: true, unless: -> {self.release_date_bitmask.nil?}
    validates :release_date_bitmask, presence: true, unless: -> {self.release_date.nil?}
    validates :end_date, presence: true, unless: -> {self.end_date_bitmask.nil?}
    validates :end_date_bitmask, presence: true, unless: -> {self.end_date.nil?}
  
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
  
  def convert_names
    @name_hash = self.namehash
    unless @name_hash.blank?
      #Convert the ones we want to convert
      @name_hash.each do |k,v|
        if [:English, :Romaji, :Japanese].include?(k)
          self.write_attribute(:name, v, locale: "hibiki_#{k.to_s.downcase[0..1]}".to_sym) unless v.nil?
          @name_hash.except!(k) #Remove the key from the hash
        end
      end
      self.namehash = (@name_hash.empty? ? nil : @name_hash)
    end
    #Remove duplicates from synonym
    @name_translations = self.name_translations.values
    self.synonyms = nil if @name_translations.include?(self.synonyms)
  end   
end
