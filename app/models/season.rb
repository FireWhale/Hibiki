class Season < ActiveRecord::Base
  #Attributes
    attr_accessible :name, :start_date, :end_date  
  
  #Modules
    include FormattingModule
  
  #Constants
    FullUpdateFields = {images: ["id", "seasonimages/", "Primary"],
                        relations_by_id: {source: [:new_source_ids, :new_source_categories, :update_source_seasons, :remove_source_seasons, SourceSeason, "source_seasons"]}}  
  
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
    has_many :imagelists, as: :model, dependent: :destroy
    has_many :images, through: :imagelists
    has_many :primary_images, -> {where "images.primary_flag = 'Primary'" }, through: :imagelists, source: :image

    has_many :source_seasons
    has_many :sources, :through => :source_seasons, dependent: :destroy
end
