require 'rails_helper'

module PaginationTests
  shared_examples "it has custom pagination" do |model|
    describe "Pagination Tests" do
      model_symbol = described_class.model_name.param_key.to_sym
      default_pages = {:album => 50,
                       :artist => 50,
                       :organization => 50,
                       :song => 50,
                       :source => 50,
                       :image => 50,
                       :post => 10,
                       :issue => 10,
                       :user => 50}
      
      it "is in the default_pages array" do
        expect(default_pages.keys).to include(model_symbol)
      end
      
      it "has a paginates_per method" do
        expect(described_class.default_per_page).to eq(default_pages[model_symbol])
      end
    end
  end
end
