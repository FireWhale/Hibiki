require 'rails_helper'

module SearchTests
  
  shared_examples "it can be solr-searched" do
    #There is no additional functionality layered onto SolrSearch.
    
    #...yet.        
  end
  
  shared_examples "it can be autocompleted" do    
      it "returns a format with 'search'"
      
      it "returns a format with 'edit'"
  end
end
