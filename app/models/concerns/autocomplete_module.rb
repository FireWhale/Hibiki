module AutocompleteModule
  
  def edit_format #for autocomplete
    "#{self.id} - #{self.internal_name}"
  end
  
  def search_format
    "#{self.internal_name}"
  end
      
end
