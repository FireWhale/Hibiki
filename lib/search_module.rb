module SearchModule
  
  def format_method #for autocomplete
    self.id.to_s + " - " + self.name
  end    
      
  def autocomplete_format
    ##Sends extra data 
    if search_context.nil? || search_context == "Full Search"    
      self.class.to_s + " - " + name 
    elsif search_context == "Model Search"
      
    elsif search_context == "Edit Search"
      id.to_s + " - " + name
    end
  end

end
