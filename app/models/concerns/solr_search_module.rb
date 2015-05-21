module SolrSearchModule
  extend ActiveSupport::Concern
  
  included do
    searchable do
      search_boost = if self.name == "Song"
                       0
                     elsif self.name == "Album"
                       3
                     else
                       5
                     end
      search_boost = (self.name == "Song") ? 0 : 5
      #These fields are for autocompletion
      text :autocomplete_search, boost: search_boost, as: :autocomplete_textp do
        read_name.uniq
      end
      text :autocomplete_edit, boost: search_boost + 5, as: :autocomplete_texte do
        #only use name_translations when editing - cuts down on erroneous artists.
        name_translations.values
      end
      
      #These fields are for the actual search
      text :internal_name, :synonyms, boost: search_boost
      text :namehash, boost: search_boost do
        namehash.blank? ? namehash : namehash.values
      end
      text :translated_names, boost: search_boost + 5 do #Translation tables
        name_translations.values
      end      
      text :reference, boost: search_boost do
        reference.blank? ? reference : reference.values
      end      
      text :catalog_number, boost: search_boost if self.name == "Album"
      
      #These fields is for ordering results
      time :release_date if self.name == "Album"
    end
  end
end