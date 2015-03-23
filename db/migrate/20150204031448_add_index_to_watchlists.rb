class AddIndexToWatchlists < ActiveRecord::Migration
  def change
    add_index :watchlists, :grouping_category
    add_index :watchlists, :position
    remove_column :watchlists, :status
  end
end
