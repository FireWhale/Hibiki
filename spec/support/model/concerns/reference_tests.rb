require 'rails_helper'

module ReferenceTests
  shared_examples "it has references" do
    describe "Reference Tests" do
      model_symbol = described_class.model_name.param_key.to_sym

      describe "Associations" do
        it "has many references" do
          record = create(model_symbol)
          record.references << create(:reference, site_name: "VGMdb")
          expect(record.references.first).to be_a Reference
          expect(described_class.reflect_on_association(:references).macro).to eq(:has_many)
        end

        it "destroys references when destroyed" do
          record = create(model_symbol)
          record.references << create(:reference, site_name: "VGMdb")
          expect{record.destroy}.to change(Reference, :count).by(-1)
        end
      end

      describe "Instance Methods" do
        it "returns a list of references for a #{model_symbol} aka super" do
          record = create(model_symbol)
          reference1 = create(:reference, site_name: "VGMdb")
          reference2 = create(:reference, site_name: "Wikipedia")
          record.references << reference1
          record.references << reference2
          expect(record.references).to match_array([reference1, reference2])
        end

        it "returns a specific reference if passed in as a parameter" do
          record = create(model_symbol)
          reference1 = create(:reference, site_name: "VGMdb")
          reference2 = create(:reference, site_name: "Wikipedia")
          record.references << reference1
          record.references << reference2
          expect(record.references("Wikipedia")).to eq(reference2)
        end

        it "accepts the one word references as a symbol" do
          record = create(model_symbol)
          reference1 = create(:reference, site_name: "VGMdb")
          reference2 = create(:reference, site_name: "Wikipedia")
          record.references << reference1
          record.references << reference2
          expect(record.references(:Wikipedia)).to eq(reference2)
        end

        it "returns nil if the specific reference site is not in the references" do
          record = create(model_symbol)
          reference = create(:reference, model: record)
          expect(record.references("hi")).to be_nil
        end
      end

      describe "Callbacks/Hooks" do
        describe "After Save: manage_references" do
          it "creates new references" do
            record = create(model_symbol)
            record.new_references = {:site_name => ["MyAnimeList"], :url => ["MyAnimeList"]}
            expect{record.save}.to change(Reference, :count).by(1)
          end

          it "doesn't create a reference if the url or site_name is blank" do
            record = create(model_symbol)
            record.new_references = {:site_name => ["hi"], :url => [""]}
            expect{record.save}.to change(Reference, :count).by(0)
          end

          it "updates references" do
            record = create(model_symbol)
            reference = create(:reference, model: record)
            record.update_references = {reference.id => {:url => "this is a url", :site_name => "CDJapan"}}
            record.save
            expect(record.references.first.url).to eq("this is a url")
          end

          it "destroys the reference if the site_name is blank" do
            record = create(model_symbol)
            reference = create(:reference, model: record)
            record.update_references = {reference.id => {:url => "this is a url", :site_name => ""}}
            expect{record.save}.to change(Reference, :count).by(-1)
          end

          it "destroys the reference if the url is blank" do
            record = create(model_symbol)
            reference = create(:reference, model: record)
            record.update_references = {reference.id => {:url => "", :site_name => "CDJapan"}}
            expect{record.save}.to change(Reference, :count).by(-1)
          end

          it "only updates a reference attached to the record" do
            record = create(model_symbol)
            record2 = create(model_symbol)
            reference = create(:reference, model: record2)
            record.update_references = {reference.id => {:url => "", :site_name => "CDJapan"}}
            expect{record.save}.to change(Reference, :count).by(0)
          end
        end
      end

    end
  end
end
