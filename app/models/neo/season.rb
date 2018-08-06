class Neo::Season
  include NodeModule

  has_many :in, :sources, type: "Aired In" , model_class: "NeoSource"

end
