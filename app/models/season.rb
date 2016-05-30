class Season < ActiveRecord::Base  
  #Concerns
    include AssociationModule
    include JsonModule
    #Association Modules
      include ImageModule
  
  #Attributes
    attr_accessor :new_sources
    attr_accessor :remove_source_seasons
    attr_accessor :update_source_seasons
    
  #Callbacks/Hooks
    after_save :manage_sources
      
  #Constants  
    FormFields = [{type: "text", attribute: :name, label: "Name"},
                  {type: "date", attribute: :start_date, label: "Start Date:"}, 
                  {type: "date", attribute: :end_date, label: "End Date:"},
                  {type: "related_model", div_class: "well", title: "Sources", model: "source", relation_model: "source_seasons", categories: SourceSeason::Categories, sub_div_id: "Sources" }, 
                  {type: "images"}]
  
  #Validations
    validates :start_date, presence: true
    validates :end_date, presence: true
    validates :name, presence: true
    
  #Associations
    has_many :source_seasons, dependent: :destroy
    has_many :sources, :through => :source_seasons
    
  private
    def manage_sources
      self.manage_primary_relation(Source,SourceSeason)
    end
end
