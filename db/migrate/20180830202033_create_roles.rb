class CreateRoles < ActiveRecord::Migration[5.2]
  def change
    create_table :roles do |t|
      t.string :name
      t.string :description

      t.timestamps
    end


    create_join_table :users, :roles, table_name: :user_roles do |t|
      t.index :user_id
      t.index :role_id

      t.timestamps
    end
  end
end
