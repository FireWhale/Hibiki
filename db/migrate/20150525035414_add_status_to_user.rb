class AddStatusToUser < ActiveRecord::Migration
  def up
    add_column :users, :status, :string
  end
end
