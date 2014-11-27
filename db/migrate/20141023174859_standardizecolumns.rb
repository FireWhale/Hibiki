class Standardizecolumns < ActiveRecord::Migration
  def up
    rename_column :albums, :catalognumber, :catalog_number
    
    rename_column :albums, :privateinfo, :private_info
    rename_column :artists, :privateinfo, :private_info
    rename_column :organizations, :privateinfo, :private_info
    rename_column :sources, :privateinfo, :private_info
    
    rename_column :albums, :releasedate, :release_date
    rename_column :albums, :releasedate_bitmask, :release_date_bitmask
    
    rename_column :artists, :debutdate, :debut_date
    rename_column :artists, :debutdate_bitmask, :debut_date_bitmask
    rename_column :artists, :birthdate, :birth_date
    rename_column :artists, :birthdate_bitmask, :birth_date_bitmask
    
    rename_column :sources, :releasedate, :release_date
    rename_column :sources, :releasedate_bitmask, :release_date_bitmask

    rename_column :sources, :enddate, :end_date
    add_column :sources, :end_date_bitmask, :integer
    
    rename_column :songs, :releasedate, :release_date
    rename_column :songs, :releasedate_bitmask, :release_date_bitmask  
    rename_column :songs, :tracknumber, :track_number
      
    
    rename_column :events, :startdate, :start_date
    rename_column :events, :enddate, :end_date
    rename_column :events, :dbcomplete, :db_status
    
    rename_column :users, :birthdate, :birth_date
    rename_column :users, :birthdate_bitmask, :birth_date_bitmask
    
    rename_table :postlist, :postlists
  end

  def down
  end
end
