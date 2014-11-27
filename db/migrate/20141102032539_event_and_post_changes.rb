class EventAndPostChanges < ActiveRecord::Migration
  def up
    remove_column :album_events, :category 
    rename_column :posts, :recipient, :user_info
  end

  def down
  end
end
