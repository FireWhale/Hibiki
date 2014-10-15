class SourceOrganization < ActiveRecord::Base
  attr_accessible :organization_id, :source_id, :category
  
  belongs_to :organization
  belongs_to :source

  Categories = [['Publisher'],['Distributor'],['Developer']]

end
