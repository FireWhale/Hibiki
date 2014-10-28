class Modifycolumns < ActiveRecord::Migration
  def up
    
    add_column :issues, :difficulty, :string
    add_column :songs, :reference, :text
    remove_column :songs, :op_ed_number
    add_column :songs, :info, :text
    add_column :songs, :private_info, :text
    add_column :songs, :releasedate, :date
    add_column :songs, :releasedate_bitmask, :integer
    add_column :songs, :altname, :string
    add_column :songs, :status, :string
    rename_column :artists, :dbcomplete, :db_status
    rename_column :organizations, :dbcomplete, :db_status
    rename_column :sources, :dbcomplete, :db_status
  end

  def down
  end
end
