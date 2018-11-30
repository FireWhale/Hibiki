class ArtistOrganization < ApplicationRecord

  include NeoRelModule

  attr_accessor :_destroy

  #Constants
    Categories = ['Member','Founder','Former Member','Label']
    
  #Associations
    belongs_to :artist
    belongs_to :organization
    
  #Validations
    validates :artist, presence: true
    validates :organization, presence: true
    validates :category, presence: true, inclusion: ArtistOrganization::Categories

    validates :artist_id, uniqueness: {scope: [:organization_id]}

  def neo_relation
    neo_rel(artist,organization)
  end
end
