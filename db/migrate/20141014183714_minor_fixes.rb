class MinorFixes < ActiveRecord::Migration
  def up
    add_column :postlist, :created_at, :datetime
    add_column :postlist, :updated_at, :datetime
    add_column :issues, :resolution, :string
    rename_column :issues, :private_description, :private_info
  end

  def down
  end
end
