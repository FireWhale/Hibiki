class NeoAlbum
  include Neo4j::ActiveNode
  id_property :uuid

  property :name

end
