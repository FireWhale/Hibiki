class RemovefromTags < ActiveRecord::Migration
  def up
    remove_column :tags, :info
    remove_column :tags, :synopsis
  end
end
