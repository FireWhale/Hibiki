class Neo::Event
  include NodeModule

  has_many :in, :albums, rel_class: 'Neo::AlbumEvent', model_class: 'Neo::Album'

  property :start_date
  property :end_date

end