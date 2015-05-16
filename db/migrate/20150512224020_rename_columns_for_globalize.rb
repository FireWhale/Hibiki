class RenameColumnsForGlobalize < ActiveRecord::Migration
  def change
    remove_index :albums, :name => 'index_albums_on_name'
    rename_column :albums, :name, :internal_name
    add_index :albums, :internal_name

    remove_index :artists, :name => 'index_artists_on_name'
    rename_column :artists, :name, :internal_name
    add_index :artists, :internal_name
    
    remove_index :songs, :name => 'index_songs_on_name'
    rename_column :songs, :name, :internal_name
    add_index :songs, :internal_name
    
    remove_index :sources, :name => 'index_sources_on_name'
    rename_column :sources, :name, :internal_name
    add_index :sources, :internal_name, length: 255
    
    remove_index :organizations, :name => 'index_organizations_on_name'
    rename_column :organizations, :name, :internal_name
    add_index :organizations, :internal_name

    remove_index :albums, :name => 'index_albums_on_altname'
    rename_column :albums, :altname, :synonyms
    add_index :albums, :synonyms

    remove_index :artists, :name => 'index_artists_on_altname'
    rename_column :artists, :altname, :synonyms
    add_index :artists, :synonyms
    
    remove_index :songs, :name => 'index_songs_on_altname'
    rename_column :songs, :altname, :synonyms
    add_index :songs, :synonyms
    
    remove_index :sources, :name => 'index_sources_on_altname'
    rename_column :sources, :altname, :synonyms
    add_index :sources, :synonyms
    
    remove_index :organizations, :name => 'index_organizations_on_altname'
    rename_column :organizations, :altname, :synonyms
    add_index :organizations, :synonyms    
  end
end
