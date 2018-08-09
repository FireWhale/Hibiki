class Neo::AlbumOrganization
  include RelModule

  from_class 'Neo::Album'
  to_class 'Neo::Organization'
  type 'Album Handled By'

  property 'Company Role'

end