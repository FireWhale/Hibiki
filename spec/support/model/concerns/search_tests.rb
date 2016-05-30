require 'rails_helper'

module SearchTests
  shared_examples "it can be solr-searched" do
    it "has the SolrSearchModule" do #Kind of a placeholder
      expect(described_class.included_modules).to include(SolrSearchModule)
    end
    #There is no additional functionality layered onto SolrSearch at this moment.

    #Can we test how we set up solr? I don't think so...
  end
end
