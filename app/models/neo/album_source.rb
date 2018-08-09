class Neo::AlbumSource
  include RelModule

  from_class 'Neo::Album'
  to_class 'Neo::Source'
  type 'Album Used In'

end