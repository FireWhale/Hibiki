require 'rails_helper'

describe UserSession do
  #Think this is all the tests it needs..
  
  
  describe "Module Tests" do
    it_behaves_like "it has form_fields"
    it_behaves_like "it has a custom json method"
  end
  
end
