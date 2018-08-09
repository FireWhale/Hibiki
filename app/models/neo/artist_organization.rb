class Neo::ArtistOrganization
  include RelModule

  from_class 'Neo::Artist'
  to_class 'Neo::Organization'
  type 'Works Under'

  property 'Member'
  property 'Founder'
  property 'Label'

end