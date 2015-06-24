require 'rails_helper'

describe Reference do
  include_examples "global model tests" #Global Tests
  
  it_behaves_like "it is a polymorphic model", [Album, Artist, Organization, Source, Song, Event, User], "model"
    
  it "is invalid with duplicate site_names on the same model" do
    model = create(:album)
    reference = create(:reference, site_name: "VGMdb", model: model)
    expect(build(:reference, site_name: "VGMdb", model: model)).to_not be_valid
  end  
  
  #Validation Tests   
    include_examples "is invalid without an attribute", :url
    include_examples "is invalid without an attribute in a category", :site_name, Reference::SiteNames, "Reference::SiteNames"
end
