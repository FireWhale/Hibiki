class AddVisibilityToTags < ActiveRecord::Migration
  def change
    add_column :tags, :visibility, :string
  end
end
