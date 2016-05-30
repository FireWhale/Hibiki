require 'rails_helper'

module LanguageTests
  shared_examples "it is a translated model" do
    describe "Translation Tests" do
      model_symbol = described_class.model_name.param_key.to_sym
      attributes = described_class.translated_attribute_names

      attributes.each do |attribute|
        describe "read_#{attribute} method" do
          it "has a read_#{attribute} method" do
            expect(build(model_symbol)).to respond_to("read_#{attribute}")
          end

          it "can receive a user" do
            expect(build(model_symbol)).to respond_to("read_#{attribute}").with(1).arguments
          end

          it "returns an array" do
            expect(build(model_symbol).send("read_#{attribute}")).to be_a(Array)
          end

          it "includes at least the translated_elements" do
            record = build(model_symbol)
            record.write_attribute(attribute, "this is a value")
            expect(record.send("read_#{attribute}")).to include("this is a value")
          end
        end
      end

      describe "Callbacks/Hooks" do
        describe "convert_names" do
          if [Event,Tag].include? described_class
            it "does not receive convert_names on save" do
              record = build(model_symbol)
              expect(record).to_not receive(:convert_names)
              record.save
            end
          else
            it "receives convert_names on save" do
              record = build(model_symbol)
              expect(record).to receive(:convert_names)
              record.save
            end

            it "converts namehash fields to translations" do
              record = build(model_symbol)
              record.namehash = {:English => "hi"}
              record.save
              expect(record.reload.name(:hibiki_en)).to eq("hi")
            end

            it "converts namehash fields that are strings to translations" do
              record = build(model_symbol)
              record.namehash = {"English" => "hi"}
              record.save
              expect(record.reload.name(:hibiki_en)).to eq("hi")
            end

            it "manage_locale_info overwrites it" do
              record = build(model_symbol)
              record.namehash = {:English => "hi"}
              record.new_name_langs = ["hah!"]
              record.new_name_lang_categories = ["hibiki_en"]
              record.save
              expect(record.reload.name(:hibiki_en)).to eq("hah!")
            end

            if described_class == Song
              it "eliminates duplicate Japanese and English names" do
                record = build(model_symbol)
                record.namehash = {:English => "hi", "Japanese" => "hi"}
                record.save
                expect(record.reload.name(:hibiki_en)).to eq("hi")
                expect(record.reload.name(:hibiki_ja)).to eq(nil)
              end

              it "eliminates duplicate names even with strings" do
                record = build(model_symbol)
                record.namehash = {"English" => "hi", :Japanese => "hi"}
                record.save
                expect(record.reload.name(:hibiki_en)).to eq("hi")
                expect(record.reload.name(:hibiki_ja)).to eq(nil)
              end

            end

          end
        end

        describe "manage_locale_info" do
          attributes.each do |attribute|
            describe "#{attribute}" do
              it "adds a language properly" do
                record = build(model_symbol)
                record.send("new_#{attribute}_langs=",["hohe!", "ara ara"])
                record.send("new_#{attribute}_lang_categories=",["hibiki_ja", "hibiki_ro"])
                record.save
                expect(record.send(attribute,:hibiki_ja)).to eq("hohe!")
                expect(record.send(attribute,:hibiki_ro)).to eq("ara ara")
              end

              it "updates locales" do
                record = build(model_symbol)
                record.send("#{attribute}_langs=",{"hibiki_ja" => "ara ara"})
                record.save
                expect(record.send(attribute,:hibiki_ja)).to eq("ara ara")
              end

              it "has priority over 'new' locales" do
                record = build(model_symbol)
                record.send("new_#{attribute}_langs=",["hohe!", "ara ara"])
                record.send("new_#{attribute}_lang_categories=",["hibiki_ja", "hibiki_ro"])
                record.send("#{attribute}_langs=",{"hibiki_ja" => "gyabo!"})
                record.save
                expect(record.send(attribute,:hibiki_ja)).to eq("gyabo!")
              end

              it "only accepts certain locales" do
                record = build(model_symbol)
                record.send("new_#{attribute}_langs=",["hohe!", "ara ara"])
                record.send("new_#{attribute}_lang_categories=",["hibiki_german", "hibiki_ro"])
                record.send("#{attribute}_langs=",{"hibiki_mandarin" => "gyabo!"})
                record.save
                expect(record.send(attribute,:hibiki_ro)).to eq("ara ara")
                expect(record.send(attribute,:hibiki_german)).to be_nil
                expect(record.send(attribute,:hibiki_mandarin)).to be_nil
              end
            end

          end

        end
      end
    end
  end
end
