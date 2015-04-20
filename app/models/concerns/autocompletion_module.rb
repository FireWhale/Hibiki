module AutocompletionModule
  
  def edit_format #for autocomplete
    "#{self.id} - #{self.name}"
  end
  
  def search_format
    "#{self.name}"
  end
      
end
