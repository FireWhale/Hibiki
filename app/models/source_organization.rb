class SourceOrganization < ActiveRecord::Base  
  #Constants
    Categories = ['Publisher','Distributor','Developer']
    
  #Associations
    belongs_to :organization
    belongs_to :source
    
  #Validations
    validates :source, presence: true
    validates :organization, presence: true
    validates :category, presence: true, inclusion: SourceOrganization::Categories
    
    validates :source_id, uniqueness: {scope: [:organization_id]}
end
