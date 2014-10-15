class ReworkPosts < ActiveRecord::Migration
  def up
    add_column :posts, :title, :string
    
    create_table :postlist do |t|
      t.integer :post_id
      t.integer :model_id
      t.string :model_type
      
      t.timestamps
    end
    
    create_table :issues do |t|
      t.string :name
      t.string :type
      t.text :description
      t.text :private_info
      t.string :status
      t.string :resolution
      t.string :priority
      t.string :visibility
      
      t.timestamps
    end
    
    create_table :issue_users do |t|
      t.integer :issue_id
      t.integer :user_id
      t.string :comment
      t.string :vote
      
      t.timestamps
    end
  end

  def down
  end
end
