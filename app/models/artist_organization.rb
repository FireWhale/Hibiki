class ArtistOrganization < ActiveRecord::Base
  attr_accessible :artist_id, :category, :organization_id  
  
  belongs_to :artist
  belongs_to :organization
  
  Categories = ['Member','Founder','Former Member','Label']

end
