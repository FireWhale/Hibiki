module ReferencesModule
  
  def format_references_hash(sites,urls)
    #This method formats an array of sites and an array of urls and 
    #adds it to the instanced record it was called upon.
    references = sites.zip(urls)
    
    self.reference = {}
    #In case links and types gets into the hash accidentally.
    self.reference.delete :types
    self.reference.delete :links
    references.each do |reference|
      if reference[0].empty? == false && reference[1].empty? == false
        hash = {reference[0].to_sym => reference[1]}
        self.reference = self.reference.merge(hash)
      end
    end
  end
  
end
