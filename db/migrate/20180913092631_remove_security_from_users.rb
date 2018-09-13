class RemoveSecurityFromUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :security, :string
  end
end
