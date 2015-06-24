class AddReferencesTable < ActiveRecord::Migration
  def up
    create_table :references do |t|
      t.integer :model_id
      t.string :model_type
      t.string :site_name
      t.string :url
      
      t.timestamps
    end    
    
    add_index :references, :model_id
    add_index :references, :model_type
    add_index :references, :site_name
  end
end
