class Databasechanges < ActiveRecord::Migration
  def up
    add_column :posts, :status, :string
    add_column :songs, :disc_number, :string
  end

  def down
  end
end
