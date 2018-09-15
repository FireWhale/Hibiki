require 'rails_helper'

module GlobalControllerTests
  shared_examples "global controller tests" do

    describe "Global Tests" do
      #Adding or removing functionality will make these tests fail

      describe "Gen View Concern" do
        if [ArtistsController, OrganizationsController,SourcesController].include?(described_class)
          it "has the collection module" do
            expect(described_class.included_modules).to include(GenViewsModule)
          end
        else
          it "does not have the collection module" do
            expect(described_class.included_modules).to_not include(GenViewsModule)
          end
        end
      end
    end
  end

end
