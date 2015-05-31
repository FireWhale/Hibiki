class AddTranslationsToTags < ActiveRecord::Migration
  def up
    remove_index(:tags, :name => 'index_tags_on_name')
    rename_column :tags, :name, :internal_name
    add_index :tags, :internal_name
    
    Tag.create_translation_table! :name => :string, :info => :text
    
    #Fix classification index name
    remove_index(:tags, :name => 'index_tags_on_category')
    add_index :tags, :classification
  end
end
