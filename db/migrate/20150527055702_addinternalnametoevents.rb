class Addinternalnametoevents < ActiveRecord::Migration
  def change
    add_column :events, :internal_name, :string
  end
end
