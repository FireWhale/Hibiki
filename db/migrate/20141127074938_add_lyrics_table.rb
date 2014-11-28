class AddLyricsTable < ActiveRecord::Migration
  def up
    create_table :lyrics do |t|
      t.string :language
      t.integer :song_id
      t.text :lyrics
      
      t.timestamps
    end
    
    remove_column :songs, :lyrics
  end

  def down
  end
end
