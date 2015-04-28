require 'rails_helper'

module AjaxTests
  #GETS - Showing info
    shared_examples 'can autocomplete' do |accessible, method|
      model_class = described_class.controller_name.classify.constantize
      model_symbol = model_class.model_name.param_key.to_sym
      
      describe 'GET #autocomplete' do
        it "matches to a route" #do
          #get "autocomplete_#{model_symbol}_#{method}".to_sym, format: :json
        #end
        #add these tests when you complete globalize implementation
        
        # it "returns a json of matches"
#         
        # it "searches on full"
#         
        # it "uses appropriate scopes"
#         
        # it "calls #{method}_format for display_value"
#         
        
      end
    end
            
end
