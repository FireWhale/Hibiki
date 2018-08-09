class Neo::AlbumEvent
  include RelModule

  from_class 'Neo::Album'
  to_class 'Neo::Event'
  type 'Released At'

end