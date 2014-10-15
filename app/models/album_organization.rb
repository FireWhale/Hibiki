class AlbumOrganization < ActiveRecord::Base
  attr_accessible :album_id, :category, :organization_id

  belongs_to :album
  belongs_to :organization
  
  Categories = [['Publisher'],['Distributor']]
end
