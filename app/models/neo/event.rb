class Neo::Event
  include NodeModule

  has_many :in, :albums, rel_class: 'Neo::AlbumEvent', model_class: 'Neo::Album'

  property 'start date'
  property 'end date'
  property 'abbreviation'
  property 'info'
  property 'shorthand'

end