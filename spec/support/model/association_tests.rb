require 'rails_helper'

module AssociationTests
  #Non-join model Tests
  shared_examples "it has a primary relation" do |related_class, join_model_class|
    include_examples "it has_many through", related_class, join_model_class, :with_primary_relations
  end

  shared_examples "it is a polymorphically-linked class" do |join_model_class, related_class_array, related_class_label|
    linked_symbol = described_class.model_name.param_key.to_sym
    join_model_string = join_model_class.model_name.singular

    related_class_array.each do |related_class|
      describe "#{related_class.name}" do
        related_class_string = related_class.model_name.singular

        include_examples "it has_many through", related_class, join_model_class, "with_#{join_model_string}_#{related_class_string}".to_sym

        if described_class == Image
          it "returns the first associated record when using #{related_class_label}" do
            instance = create(linked_symbol, "with_#{join_model_string}_#{related_class_string}".to_sym)
            expect(instance.send(related_class_label)).to be_a related_class
          end
        end
      end
    end

    if join_model_class == Watchlist
      it "returns a group of records using watching" do
        instance = create(linked_symbol, "with_multiple_#{join_model_string}s".to_sym)
        expect(instance.watching.count).to eq(related_class_array.count)
      end
    elsif join_model_class == Collection
      it "returns a group of records using collecting" do
        instance = create(linked_symbol, "with_multiple_#{join_model_string}s".to_sym)
        expect(instance.collecting.count).to eq(related_class_array.count)
      end
    else
      it "returns a group of records using #{related_class_label}s" do
        instance = create(linked_symbol, "with_multiple_#{join_model_string}s".to_sym)
        expect(instance.send("#{related_class_label}s").count).to eq(related_class_array.count)
      end
    end


    #This is not a legit test. That's asking for an activerelation that
    #has different models in an array fashion. kinda ridiculous.
    #ie: ActiveRelation [<Song>, <Image>, <Album>]
    # it "returns a group of records using #{related_class_label}s as an activerecord association" do
      # instance = create(linked_symbol, "with_multiple_#{join_model_string}s".to_sym)
      # expect(instance.send("#{related_class_label}s").class).to_not eq(Array)
    # end

  end

  shared_examples "it has_many through" do |related_class, join_model_class, trait|
    related_class_string = related_class.model_name.singular
    related_class_symbol = related_class.model_name.param_key.to_sym
    join_model_string = join_model_class.model_name.singular
    join_model_symbol = join_model_class.model_name.param_key.to_sym
    class_symbol = described_class.model_name.param_key.to_sym
    related_class_label = related_class.model_name.plural


    #Associations
      it "is valid with #{join_model_string}" do
        expect(build(class_symbol, trait)).to be_valid
      end

      it "has many #{join_model_string}s" do
        expect(create(class_symbol, trait).send(join_model_class.model_name.plural).first).to be_a join_model_class
        expect(described_class.reflect_on_association(join_model_class.model_name.plural.to_sym).macro).to eq(:has_many)
      end

      it "has many #{related_class_string}s" do
        expect(create(class_symbol, trait).send(related_class_label).first).to be_a related_class
        expect(described_class.reflect_on_association(related_class_label.to_sym).macro).to eq(:has_many)
      end

      it "destroys #{join_model_string}s when destroyed" do
        record = create(class_symbol, trait)
        expect{record.destroy}.to change(join_model_class, :count).by(-1)
      end

      it "does not destroy #{related_class_string}s when destroyed" do
        record = create(class_symbol, trait)
        expect{record.destroy}.to change(related_class, :count).by(0)
      end

    #Validations
      it "is valid with multiple #{join_model_string}s" do
        if class_symbol == :tag
          record = create(class_symbol, model_bitmask: 63)
        else
          record = create(class_symbol)
        end
        number = Array(3..10).sample
        list = create_list(join_model_symbol, number, class_symbol => record)
        expect(record.send(join_model_class.model_name.plural)).to match_array(list)
        expect(record).to be_valid
      end

      it "is valid with multiple #{related_class_string}s" do
        if class_symbol == :tag
          record = create(class_symbol, model_bitmask: 63)
        else
          record = create(class_symbol)
        end
        number = Array(3..10).sample
        if [Imagelist, Postlist, Taglist, Loglist, Watchlist, Collection].include?(join_model_class)
          join_trait = "with_#{related_class_string}".to_sym
          list = create_list(join_model_symbol, number, join_trait, class_symbol => record)
        else
          list = create_list(join_model_symbol, number, class_symbol => record)
        end
        expect(record.send(related_class_label).count).to eq(number)
        expect(record).to be_valid
      end
  end

  #Join Model Tests
  shared_examples "a join table" do |model_1, model_2|
    join_table_symbol = described_class.model_name.param_key.to_sym
    model_1_string = model_1.model_name.singular
    model_1_symbol = model_1.model_name.param_key.to_sym
    model_2_string = model_2.model_name.singular
    model_2_symbol = model_2.model_name.param_key.to_sym

    #Associations
      it "belongs to a #{model_1_string}" do
        expect(create(join_table_symbol).send(model_1_string)).to be_a model_1
        expect(described_class.reflect_on_association(model_1_symbol).macro).to eq(:belongs_to)
      end

      it "belongs to a #{model_2_string}" do
        expect(create(join_table_symbol).send(model_2_string)).to be_a model_2
        expect(described_class.reflect_on_association(model_2_symbol).macro).to eq(:belongs_to)
      end

      it "does not destroy #{model_1_string} when destroyed" do
        record = create(join_table_symbol)
        expect{record.destroy}.to change(model_1, :count).by(0)
      end

      it "does not destroy #{model_2_string} when destroyed" do
        record = create(join_table_symbol)
        expect{record.destroy}.to change(model_2, :count).by(0)
      end

    #Validation
      it "is valid with a #{model_1_string} and a #{model_2_string}" do
        expect(build(join_table_symbol)).to be_valid
      end

      it "is invalid without a #{model_1_string}" do
        expect(build(join_table_symbol, model_1_symbol => nil)).to_not be_valid
      end

      it "is invalid without a real #{model_1_string}" do
        expect(build(join_table_symbol, "#{model_1_string}_id".to_sym => 999999999)).to_not be_valid
      end

      it "is invalid without a #{model_2_string}" do
        expect(build(join_table_symbol, model_2_symbol => nil)).to_not be_valid
      end

      it "is invalid without a real #{model_2_string}" do
        expect(build(join_table_symbol,  "#{model_2_string}_id".to_sym => 999999999)).to_not be_valid
      end

      it "should have a unique #{model_1}/#{model_2} combination" do
        model1 = create(model_1_symbol)
        model2 = create(model_2_symbol)
        expect(create(join_table_symbol, model_1_symbol => model1, model_2_symbol => model2)).to be_valid
        expect(build(join_table_symbol, model_1_symbol => model1, model_2_symbol => model2)).to_not be_valid
      end
  end

  shared_examples "it is a polymorphic model" do |polyclasses, poly_label|
    model_symbol = described_class.model_name.param_key.to_sym

    polyclasses.each do |polyclass|
      polyclass_symbol = polyclass.model_name.param_key.to_sym

      it "belongs to a #{polyclass_symbol}" do
        polyrecord = create(polyclass_symbol)
        expect(build(model_symbol, poly_label.to_sym => polyrecord).send(poly_label)).to be_a polyclass
        expect(described_class.reflect_on_association(poly_label.to_sym).macro).to eq(:belongs_to)
      end

      it "does not destroy #{polyclass_symbol}s when destroyed" do
        polyrecord = create(polyclass_symbol)
        record = create(model_symbol, poly_label.to_sym => polyrecord)
        expect{record.destroy}.to change(polyclass, :count).by(0)
      end
    end

    polyclasses.each do |polyclass|
      polyclass_symbol = polyclass.model_name.param_key.to_sym
      polyclass_string = polyclass.model_name.singular

      it "is valid with an #{polyclass_string}" do
        expect(build(model_symbol, "with_#{polyclass_string}".to_sym)).to be_valid
      end

      it "is invalid without a real #{poly_label}" do
        expect(build(model_symbol, "#{poly_label}_type" => polyclass.to_s, "#{poly_label}_id" => 2147483647)).to_not be_valid
      end
    end

    it "is invalid without a #{poly_label}_type" do
      expect(build(model_symbol, "#{poly_label}_type" => nil)).to_not be_valid
    end

    it "is invalid without a #{poly_label}_id" do
      expect(build(model_symbol, "#{poly_label}_id" => nil)).to_not be_valid
    end

  end

  shared_examples "it is a polymorphic join model" do |linked_class, polyclasses, poly_label|
    model_symbol = described_class.model_name.param_key.to_sym
    linked_class_symbol = linked_class.model_name.param_key.to_sym
    linked_class_string = linked_class.model_name.singular

    include_examples "it is a polymorphic model", polyclasses, poly_label

    #Association Tests
      it "belongs to a #{linked_class_string}" do
        expect(build(model_symbol).send(linked_class_string)).to be_a linked_class
        expect(described_class.reflect_on_association(linked_class_symbol).macro).to eq(:belongs_to)
      end

      unless described_class == Imagelist #Destroying an Imagelist that orphans an image destroys that image as well. Tests are included in image.spec
        it "does not destroy #{linked_class_string} when destroyed" do
          record = create(model_symbol)
          expect{record.destroy}.to change(linked_class, :count).by(0)
        end
      end

    #Validations
      it "is valid with a #{linked_class_string}" do
        if linked_class_symbol == :tag
          record = create(linked_class_symbol, model_bitmask: 63)
        else
          record = create(linked_class_symbol)
        end
        expect(build(model_symbol, linked_class_symbol => record)).to be_valid
      end

      it "is invalid without a #{linked_class_string}" do
        expect(build(model_symbol, linked_class_symbol => nil)).to_not be_valid
      end

      it "is invalid without a real #{linked_class_string}" do
        expect(build(model_symbol, "#{linked_class_string}_id".to_sym => 9999999)).to_not be_valid
      end

      it "is valid with unique #{linked_class_string}/#{poly_label}_type combinations" do
        if linked_class_symbol == :tag
          linked_record = create(linked_class_symbol, model_bitmask: 63)
        else
          linked_record = create(linked_class_symbol)
        end
        expect(create(model_symbol, linked_class_symbol => linked_record)).to be_valid
        expect(build(model_symbol, linked_class_symbol => linked_record)).to be_valid
      end

      it "is invalid with duplicate #{linked_class_string}/#{poly_label} combination" do
        if linked_class_symbol == :tag
          linked_record = create(linked_class_symbol, model_bitmask: 63)
        else
          linked_record = create(linked_class_symbol)
        end
        poly_record = create(polyclasses[0].to_s.downcase.to_sym)
        expect(create(model_symbol, linked_class_symbol=> linked_record, poly_label.to_sym => poly_record)).to be_valid
        expect(build(model_symbol, linked_class_symbol => linked_record, poly_label.to_sym => poly_record)).to_not be_valid
      end

  end

end
