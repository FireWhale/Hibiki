require 'rails_helper'

module JsonTests
  shared_examples "it has a custom json method" do
    describe "JSON Tests" do
      model_symbol = described_class.model_name.param_key.to_sym
      let(:record) {create(model_symbol, :full_attributes)}
      
      it "returns the right attributes" do
        #This test specifies which attributse are supposed to be converted to json.
        #the actual functionality only removes invalid attributes
        #This will catch any added attributes and throw an error.
        #This test is strict, meaning it will error extra and missing attributes.
        expect(record.to_json).to match_json_schema(model_symbol.to_s)
      end
      
      context "with autocomplete options" do
        if [Artist, Source, Organization, Song, Album].include?(described_class)
          it "has an autocomplete_search form" do
            expect(record.to_json(:autocomplete_search => true)).to match_json_schema("autocomplete")
          end
          
          it "has an autocomplete_edit form" do
            record = create(model_symbol)
            expect(record.to_json(:autocomplete_edit => true)).to match_json_schema("autocomplete")
          end
        else
          it "ignores the autocomplete_search option" do
            expect(record.to_json(:autocomplete_search => true)).to match_json_schema(model_symbol.to_s)
          end
          
          it "ignores the autocomplete_edit option" do
            expect(record.to_json(:autocomplete_edit => true)).to match_json_schema(model_symbol.to_s)
          end
        end
      end
      
      context "with watchlist/collection options" do
        if described_class == User
          it "has a watchlists form"
          
          it "has a collections form"
        else
          it "ignores the watchlists option" do
            expect(record.to_json(:watchlists => true)).to match_json_schema(model_symbol.to_s)
          end
          
          it "ignores the collections option" do
            expect(record.to_json(:collections => true)).to match_json_schema(model_symbol.to_s)
          end          
        end
      end
      
    end
  end
end
