require 'rails_helper'

module PartialDateTests
  shared_examples "it has partial dates" do
    date_names = described_class.attribute_names.select { |n| described_class.attribute_names.include?("#{n}_bitmask") }
    model_symbol = described_class.model_name.param_key.to_sym

    describe "Instance Methods" do

      describe "has a format method" do

        date_names.each do |date_name|

          it "responds to the #{date_name}_formatted" do
            record = build(model_symbol)
            expect(record).to respond_to("#{date_name}_formatted")
          end

          it "formats a bitmask of 0 into a full date" do
            record = build(model_symbol, "#{date_name}": Date.new(1993,3,14), "#{date_name}_bitmask": 0)
            expect(record.send("#{date_name}_formatted")).to eq("March 14, 1993")
          end

          it "formats a bitmask of 1 into a just month and day" do
            record = build(model_symbol,  "#{date_name}": Date.new(1993,3,14), "#{date_name}_bitmask": 1)
            expect(record.send("#{date_name}_formatted")).to eq("March 14")
          end

          it "formats a bitmask of 4 into just just year and month" do
            record = build(model_symbol,  "#{date_name}": Date.new(1993,3,14), "#{date_name}_bitmask": 4)
            expect(record.send("#{date_name}_formatted")).to eq("March 1993")
          end

          it "formats a bitmask of 6 into just year" do
            record = build(model_symbol,  "#{date_name}": Date.new(1993,3,14), "#{date_name}_bitmask": 6)
            expect(record.send("#{date_name}_formatted")).to eq("1993")
          end

          it "formats a bitmask of 7 into nil" do
            record = build(model_symbol, "#{date_name}": Date.new(1993,3,14), "#{date_name}_bitmask": 7)
            expect(record.send("#{date_name}_formatted")).to be_nil
          end

        end
      end
    end
  end
end
