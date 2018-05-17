class AlbumOrganization < ApplicationRecord
  #Constants
    Categories = ['Publisher','Distributor']
    
  #Associations
    belongs_to :album
    belongs_to :organization
    
  #Validations
    validates :album, presence: true
    validates :organization, presence: true
    validates :category, presence: true, inclusion: AlbumOrganization::Categories
    
    validates :album_id, uniqueness: {scope: [:organization_id]}

end
