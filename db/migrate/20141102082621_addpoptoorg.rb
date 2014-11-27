class Addpoptoorg < ActiveRecord::Migration
  def up
    add_column :organizations, :popularity, :integer
  end

  def down
  end
end
