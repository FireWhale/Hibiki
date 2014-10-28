class Fixcomments < ActiveRecord::Migration
  def up
    change_column :issue_users, :comment, :text
  end

  def down
  end
end
