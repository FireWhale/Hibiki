# encoding: utf-8
require 'faker'

FactoryBot.define do
  factory :event do
    #Required Attributes
    internal_name {Faker::Lorem.sentence}

    trait :full_attributes do
      start_date {Faker::Date.between(5.years.ago, Date.today)}
      end_date {Faker::Date.between(5.years.ago, Date.today)}
      db_status {Artist::DatabaseStatus.sample}
      shorthand {Faker::Lorem.sentence}

      with_name_translations
      with_info_translations
      with_abbreviation_translations
    end

    trait :form_input do
      start_date {Faker::Date.between(5.years.ago, Date.today)}
      end_date {Faker::Date.between(5.years.ago, Date.today)}
      db_status {Artist::DatabaseStatus.sample}
      shorthand {Faker::Lorem.sentence}

      reference_form_attributes
      name_form_attributes
      info_form_attributes
      abbreviation_form_attributes
    end

    trait :with_album_event do
      after(:create) {|event| create(:album_event, event: event)}
    end

    trait :with_albums do
      after(:create) {|event| 5.times { create(:album_event,event: event, album: create(:album, :full_attributes))}}
    end

    trait(:invalid) {internal_name ""}
  end

  factory :album_event do
    association :album
    association :event

    trait :full_attributes do
      #nothing to add
    end
  end
end