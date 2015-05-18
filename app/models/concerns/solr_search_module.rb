module SolrSearchModule
  extend ActiveSupport::Concern
  
  included do
    searchable do
      text :internal_name, :synonyms 
      text :namehash do
        namehash.blank? ? namehash : namehash.values
      end
      text :translated_names, boost: 5 do #Translation tables
        name_translations.values
      end      
      text :reference do
        reference.blank? ? reference : reference.values
      end
      
      text :catalog_number if self.name == "Album"
      time :release_date if self.name == "Album" #needed to sort by date
    end
  end
end