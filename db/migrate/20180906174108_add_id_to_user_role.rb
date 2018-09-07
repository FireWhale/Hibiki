class AddIdToUserRole < ActiveRecord::Migration[5.2]
  def change
    add_column :user_roles, :id, :primary_key
  end
end
