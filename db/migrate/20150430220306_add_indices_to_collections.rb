class AddIndicesToCollections < ActiveRecord::Migration
  def change
    remove_index(:collections, :name => 'index_collections_on_album_id')
    
    add_index :collections, :collected_id
    add_index :collections, :collected_type
  end
end
