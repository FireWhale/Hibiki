require 'rails_helper'

module LogTests
  shared_examples "it has logs" do
    describe "Log Tests" do
      model_symbol = described_class.model_name.param_key.to_sym

      describe "Associations" do
        it "has many loglists" do
          expect(create(model_symbol, :with_log).loglists.first).to be_a Loglist
          expect(described_class.reflect_on_association(:loglists).macro).to eq(:has_many)
        end

        it "has many logs" do
          expect(create(model_symbol, :with_log).logs.first).to be_a Log
          expect(described_class.reflect_on_association(:logs).macro).to eq(:has_many)
        end

        it "destroys loglists when destroyed" do
          record = create(model_symbol, :with_log)
          expect{record.destroy}.to change(Loglist, :count).by(-1)
        end

        it "does not destroy logs when destroyed" do
          record = create(model_symbol, :with_log)
          expect{record.destroy}.to change(Log, :count).by(0)
        end

        it "returns a list of logs who are mentioning this #{model_symbol}" do
          #This tests the :through option
          record = create(model_symbol)
          list = create_list(:loglist, 3, model: record)
          expect(record.logs).to eq(list.map(&:log))
        end
      end
    end
  end
end
