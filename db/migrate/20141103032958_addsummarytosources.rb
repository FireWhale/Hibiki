class Addsummarytosources < ActiveRecord::Migration
  def up
    add_column :sources, :plot_summary, :text
  end

  def down
  end
end
