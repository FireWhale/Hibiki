class RenameTypetoCategory < ActiveRecord::Migration
  def up
    rename_column :issues, :type, :category
  end

  def down
  end
end
