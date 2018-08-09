class AlbumOrganization < ApplicationRecord

  include NeoRelModule

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


  def neo_relation
    neo_rel(album,organization)
  end

end
