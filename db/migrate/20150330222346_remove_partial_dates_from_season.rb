class RemovePartialDatesFromSeason < ActiveRecord::Migration
  def change
    remove_column :seasons, :start_date_bitmask
    remove_column :seasons, :end_date_bitmask
  end
end
