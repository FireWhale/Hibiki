# encoding: utf-8
require 'faker'

FactoryGirl.define do
  factory :season do
    name {Faker::Lorem.word}
    start_date {Faker::Date.between(2.years.ago, Date.today)}
    end_date {Faker::Date.between(2.years.ago, Date.today)}

    trait(:full_attributes) do
      #Nothing to add
    end

    trait :form_input do
      new_sources {{id: ["1,4"], category: [SourceSeason::Categories.sample, SourceSeason::Categories.sample]}}
      remove_source_seasons ["5"]
      update_source_seasons {{"1" => {:category => SourceSeason::Categories.sample}}}

      image_form_attributes
    end

    trait :with_source_season do
      after(:create) {|season| create(:source_season, season: season)}
    end

    trait(:invalid) {name ""}
  end

  factory :source_season do
    category {SourceSeason::Categories.sample}
    association :source
    association :season

    trait(:full_attributes) do
      #nothing to add
    end
  end
end