class RemoveExtraFieldsFromEvents < ActiveRecord::Migration
  def change
    remove_column :events, :name
    remove_column :events, :info
    remove_column :events, :altname
    remove_column :events, :abbreviation
    add_index :events, :internal_name
  end
end
