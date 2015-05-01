class TrimUserFunctionality < ActiveRecord::Migration
  def change
    #Remove issue_users completely
    drop_table :issue_users
    
    #Alter post columns
    remove_column :posts, :user_id
    remove_column :posts, :recipient_id
    remove_column :posts, :user_info
    
    #remove ratins completely
    drop_table :ratings
    
    #change collections to polymorphic
    rename_column :collections, :album_id, :collected_id
    add_column :collections, :collected_type, :string
    add_column :collections, :user_comment, :string
    add_column :collections, :date_obtained, :date
    add_column :collections, :date_obtained_bitmask, :integer
  end
end
