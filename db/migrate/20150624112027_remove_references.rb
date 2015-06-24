class RemoveReferences < ActiveRecord::Migration
  def change
    
    remove_column :albums, :reference
    remove_column :artists, :reference
    remove_column :organizations, :reference
    remove_column :sources, :reference
    remove_column :songs, :reference
    remove_column :events, :reference
  end
end
