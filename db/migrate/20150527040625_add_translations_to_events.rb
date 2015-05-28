class AddTranslationsToEvents < ActiveRecord::Migration
  def up
    Event.create_translation_table! :name => :string, :abbreviation => :string, :info => :text
  end
end
