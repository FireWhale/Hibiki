class Neo::Event
  include NodeModule

  property :start_date
  property :end_date

  has_many :in, :albums, type: :released_at, model_class: "Neo::Album"

end