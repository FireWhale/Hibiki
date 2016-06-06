class AddLogModel < ActiveRecord::Migration
  def change
    create_table :logs do |t|
      t.text :content, :limit => 150000
      t.string :category
      t.timestamps
    end

    create_table :loglists do |t|
      t.integer :log_id
      t.integer :model_id
      t.string :model_type
      t.timestamps
    end

    add_index :loglists, :log_id
    add_index :loglists, :model_id
    add_index :loglists, :model_type
  end
end
