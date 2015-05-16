class AddTranslationTables < ActiveRecord::Migration
  def up
    Album.create_translation_table! :name => :string, :info => :text
    Artist.create_translation_table! :name => :string, :info => :text
    Song.create_translation_table! :name => :string, :info => :text, :lyrics => :text
    Organization.create_translation_table! :name => :string, :info => :text
    Source.create_translation_table! :name => {type: :string, limit: 1000}, :info => :text    
  end
end
