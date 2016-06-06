require 'rails_helper'

module AssociationModuleTests

    shared_examples "it has the association module" do

      it "has the AssociationModule" do #Kind of a placeholder
        expect(described_class.included_modules).to include(AssociationModule)
      end
    end

    shared_examples "manages a primary association" do |primary_model, join_model|
      model_symbol = described_class.model_name.param_key.to_sym
      join_model_symbol = join_model.model_name.singular.to_sym

      unless (described_class == Album && [Event,Source].include?(primary_model))
        it "updates all of a relation's attributes" do
          record = create(model_symbol)
          join_record = create(join_model_symbol, model_symbol => record)
          new_attributes = attributes_for(join_model_symbol, :full_attributes)
          record.send("update_#{join_model.model_name.plural}=", {join_record.id => new_attributes})
          record.save
          new_attributes.each { |k,v| expect(join_record.reload.send(k)).to eq(v) }
        end

        it "doesn't update a record not on the record" do
          record = create(model_symbol)
          record2 = create(model_symbol)
          join_record = create(join_model_symbol, model_symbol => record)
          join_record2 = create(join_model_symbol, model_symbol => record2)
          old_attributes = join_record2.attributes.slice(*(attributes_for(join_model_symbol).keys.map { |v| v.to_s }))
          new_attributes = attributes_for(join_model_symbol, :full_attributes)
          record.send("update_#{join_model.model_name.plural}=", {join_record2.id => new_attributes})
          expect_any_instance_of(join_model).to_not receive(:update_attributes)
          record.save
          old_attributes.each { |k,v| expect(join_record2.reload.send(k)).to eq(v) }
        end
      end

      it "creates a new relation record" do
        record = create(model_symbol)
        primary_record = create(primary_model.model_name.singular.to_sym)
        new_attributes = attributes_for(join_model_symbol)
        new_attributes.each { |k,v| new_attributes[k] = [v] }
        new_attributes["id"] = [primary_record.id]
        record.send("new_#{primary_model.model_name.plural}=", new_attributes)
        expect{record.save}.to change(join_model, :count).by(1)
      end

      it "creates multiple new records" do
        record = create(model_symbol)
        primary_record1 = create(primary_model.model_name.singular.to_sym)
        primary_record2 = create(primary_model.model_name.singular.to_sym)
        primary_record3 = create(primary_model.model_name.singular.to_sym)
        new_attributes1 = attributes_for(join_model_symbol)
        new_attributes2 = attributes_for(join_model_symbol)
        new_attributes3 = attributes_for(join_model_symbol)
        new_attributes1.each { |k,v| new_attributes1[k] = [v] }
        new_attributes2.each { |k,v| new_attributes1[k] << v }
        new_attributes3.each { |k,v| new_attributes1[k] << v }
        new_attributes1["id"] = [primary_record1.id, primary_record2.id, primary_record3.id]
        record.send("new_#{primary_model.model_name.plural}=", new_attributes1)
        expect{record.save}.to change(join_model, :count).by(3)
      end

      it "creates records with all the optional categories" do
        record = create(model_symbol)
        primary_record = create(primary_model.model_name.singular.to_sym)
        new_attributes = attributes_for(join_model_symbol, :full_attributes)
        new_hash = new_attributes.inject({}) { |h,(k,v)| h[k] = [v]; h }
        new_hash["id"] = [primary_record.id]
        record.send("new_#{primary_model.model_name.plural}=", new_hash)
        record.save
        expect(record.send(join_model.model_name.plural).first).to have_attributes(new_attributes)
      end

      if described_class == Album && [Organization,Source,Event].include?(primary_model)
        it "can add records by internal_name" do
          record = create(model_symbol)
          primary_record = create(primary_model.model_name.singular.to_sym)
          new_attributes = attributes_for(join_model_symbol, :full_attributes)
          new_hash = new_attributes.inject({}) { |h,(k,v)| h[k] = [v]; h }
          new_hash["internal_name"] = [primary_record.internal_name]
          record.send("new_#{primary_model.model_name.plural}_by_name=", new_hash)
          expect{record.save}.to change(join_model, :count).by(1)
          expect(record.send(join_model.model_name.plural).first).to have_attributes(new_attributes)
        end

        it "can add records by internal_name and id at the same time" do
          record = create(model_symbol)
          primary_record = create(primary_model.model_name.singular.to_sym)
          primary_record2 = create(primary_model.model_name.singular.to_sym)
          new_attributes = attributes_for(join_model_symbol, :full_attributes)
          new_attributes2 = attributes_for(join_model_symbol, :full_attributes)
          new_hash = new_attributes.inject({}) { |h,(k,v)| h[k] = [v]; h }
          new_hash["internal_name"] = [primary_record.internal_name]
          new_hash2 = new_attributes2.inject({}) { |h,(k,v)| h[k] = [v]; h }
          new_hash2["id"] = [primary_record2.id]
          record.send("new_#{primary_model.model_name.plural}_by_name=", new_hash)
          record.send("new_#{primary_model.model_name.plural}=", new_hash2)
          expect{record.save}.to change(join_model, :count).by(2)
        end

        it "creates #{primary_model.model_name.plural} if they don't exist" do
          record = create(model_symbol)
          new_attributes = attributes_for(join_model_symbol, :full_attributes)
          new_hash = new_attributes.inject({}) { |h,(k,v)| h[k] = [v]; h }
          new_hash["internal_name"] = ["new record"]
          record.send("new_#{primary_model.model_name.plural}_by_name=", new_hash)
          expect{record.save}.to change(join_model, :count).by(1)
          expect(record.send(primary_model.model_name.plural).first.internal_name).to eq("new record")
        end
      end

      it "destroys relations" do
        record = create(model_symbol)
        join_record = create(join_model_symbol, model_symbol => record)
        record.send("remove_#{join_model.model_name.plural}=", [join_record.id])
        expect{record.save}.to change(join_model, :count).by(-1)
      end

      it "doesn't destroy a relation not on the record" do
        record = create(model_symbol)
        record2 = create(model_symbol)
        join_record = create(join_model_symbol, model_symbol => record)
        join_record2 = create(join_model_symbol, model_symbol => record2)
        record.send("remove_#{join_model.model_name.plural}=", [join_record2.id])
        expect_any_instance_of(join_model).to_not receive(:destroy)
        expect{record.save}.to change(join_model, :count).by(0)
      end


    end

    shared_examples "manages an artist association" do
      model_symbol = described_class.model_name.param_key.to_sym
      join_model = "Artist#{described_class.model_name.singular.capitalize}".constantize
      join_model_symbol = join_model.model_name.singular.to_sym

      it "updates a relation!" do
        record = create(model_symbol)
        join_record = create(join_model_symbol, model_symbol => record)
        credits = Artist::Credits.sample(4)
        params = {join_record.id.to_s => {:category => credits}}
        record.send("update_artist_#{described_class.model_name.plural}=", params)
        record.save
        expect(join_record.reload.category).to eq(Artist.get_bitmask(credits).to_s)
      end

      it "updates a relation's display name translations" do
        record = create(model_symbol)
        join_record = create(join_model_symbol, model_symbol => record)
        credits = Artist::Credits.sample(4)
        params = {join_record.id.to_s => {:category => credits,
                                          :display_name => {:names => ["eng!"], :languages => [:hibiki_en]}}}
        record.send("update_artist_#{described_class.model_name.plural}=", params)
        record.save
        expect(join_record.reload.category).to eq(Artist.get_bitmask(credits).to_s)
        expect(join_record.display_name(:hibiki_en)).to eq("eng!")
      end

      it "doesn't update a relation not on the record" do
        record = create(model_symbol)
        join_record = create(join_model_symbol)
        credits = Artist::Credits.sample(4)
        params = {join_record.id.to_s => {:category => credits}}
        record.send("update_artist_#{described_class.model_name.plural}=", params)
        expect_any_instance_of(join_model).to_not receive(:update_attributes)
        record.save
      end

      it "destroys relations if the categories are empty" do
        record = create(model_symbol)
        join_record = create(join_model_symbol, model_symbol => record)
        credits = []
        params = {join_record.id.to_s => {:category => credits}}
        record.send("update_artist_#{described_class.model_name.plural}=", params)
        expect{record.save}.to change(join_model, :count).by(-1)
      end

      it "doesn't destroy a relation not on the record" do
        record = create(model_symbol)
        join_record = create(join_model_symbol)
        credits = []
        params = {join_record.id.to_s => {:category => credits}}
        record.send("update_artist_#{described_class.model_name.plural}=", params)
        expect{record.save}.to change(join_model, :count).by(0)
      end

      it "creates a new artist relation record" do
        record = create(model_symbol)
        artist = create(:artist)
        credits = Artist::Credits.sample(4)
        params = {"id" => [artist.id], :category => credits}
        record.new_artists = params
        expect{record.save}.to change(join_model, :count).by(1)
      end

      it "adds the credits properly to new relations" do
        record = create(model_symbol)
        artist = create(:artist)
        credits = Artist::Credits.sample(4)
        params = {"id" => [artist.id], :category => credits}
        record.new_artists = params
        record.save
        expect(record.send("artist_#{model_symbol}s").first.category).to eq(Artist.get_bitmask(credits).to_s)
      end

      it "adds display_name translations to new relations" do
        record = create(model_symbol)
        artist = create(:artist)
        credits = Artist::Credits.sample(4)
        params = {"id" => [artist.id], :category => credits,
                  :display_name => {:names => ["eng!", "japanese!"], :languages => [:hibiki_en, :hibiki_ja]}}
        record.new_artists = params
        record.save
        expect(record.send("artist_#{model_symbol}s").first.display_name(:hibiki_ja)).to eq("japanese!")
      end

      it "creates multiple new records" do
        record = create(model_symbol)
        artist = create(:artist)
        artist2 = create(:artist)
        credits = Artist::Credits.sample(4)
        credits2 = Artist::Credits.sample(3)
        params = {"id" => [artist.id, artist2.id], :category => (credits + ["New Artist"] + credits2)}
        record.new_artists = params
        record.save
        expect(record.send("artist_#{model_symbol}s").first.category).to eq(Artist.get_bitmask(credits).to_s)
        expect(record.send("artist_#{model_symbol}s")[1].category).to eq(Artist.get_bitmask(credits2).to_s)
      end

      it "can add by name instead of id" do
        record = create(model_symbol)
        artist = create(:artist)
        artist2 = create(:artist)
        credits = Artist::Credits.sample(4)
        credits2 = Artist::Credits.sample(3)
        params = {"internal_name" => [artist.internal_name, artist2.internal_name], :category_by_name => (credits + ["New Artist"] + credits2)}
        record.new_artists = params
        expect{record.save}.to change(join_model, :count).by(2)
        expect(record.send("artist_#{model_symbol}s").first.category).to eq(Artist.get_bitmask(credits).to_s)
        expect(record.send("artist_#{model_symbol}s")[1].category).to eq(Artist.get_bitmask(credits2).to_s)
      end

      it "adds by both name and id" do
        record = create(model_symbol)
        artist = create(:artist)
        artist2 = create(:artist)
        credits = Artist::Credits.sample(4)
        credits2 = Artist::Credits.sample(3)
        params = {"id" => [artist.id], "category" => credits,
                  "internal_name" => [artist2.internal_name], :category_by_name => credits2}
        record.new_artists = params
        expect{record.save}.to change(join_model, :count).by(2)
        expect(record.send("artist_#{model_symbol}s").first.category).to eq(Artist.get_bitmask(credits).to_s)
        expect(record.send("artist_#{model_symbol}s")[1].category).to eq(Artist.get_bitmask(credits2).to_s)
      end

      it "creates an artist if the internal_name isn't found" do
        record = create(model_symbol)
        credits = Artist::Credits.sample(4)
        params = {"internal_name" => ["new name"], :category_by_name => (credits)}
        record.new_artists = params
        expect{record.save}.to change(Artist, :count).by(1)
      end
    end
end
