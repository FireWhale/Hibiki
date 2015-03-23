class AddDimensionsToImages < ActiveRecord::Migration
  def change
    add_column :images, :width, :integer
    add_column :images, :height, :integer
    add_column :images, :medium_width, :integer
    add_column :images, :medium_height, :integer
    add_column :images, :thumb_width, :integer
    add_column :images, :thumb_height, :integer
  end
end
