class ForceCreateNeoNodeUuidConstraint < Neo4j::Migrations::Base
  def up
    add_constraint :NeoAlbum, :uuid, force: true
    add_constraint :NeoArtist, :uuid, force: true
    add_constraint :NeoEvent, :uuid, force: true
    add_constraint :NeoOrganization, :uuid, force: true
    add_constraint :NeoSeason, :uuid, force: true
    add_constraint :NeoSong, :uuid, force: true
    add_constraint :NeoSource, :uuid, force: true
  end

  def down
    drop_constraint :NeoAlbum, :uuid
    drop_constraint :NeoArtist, :uuid
    drop_constraint :NeoEvent, :uuid
    drop_constraint :NeoOrganization, :uuid
    drop_constraint :NeoSeason, :uuid
    drop_constraint :NeoSong, :uuid
    drop_constraint :NeoSource, :uuid
  end
end
