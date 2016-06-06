class AddTranslationsToArtistAlbumSong < ActiveRecord::Migration
  def up
    ArtistAlbum.create_translation_table! :display_name => :string
    ArtistSong.create_translation_table! :display_name => :string
  end

  def down
    ArtistAlbum.drop_translation_table!
    ArtistSong.drop_translation_table!
  end
end
