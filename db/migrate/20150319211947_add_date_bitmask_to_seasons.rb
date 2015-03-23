class AddDateBitmaskToSeasons < ActiveRecord::Migration
  def change
    add_column :seasons, :start_date_bitmask, :integer
    add_column :seasons, :end_date_bitmask, :integer
  end
end
