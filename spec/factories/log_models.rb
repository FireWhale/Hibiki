# encoding: utf-8
require 'faker'

FactoryBot.define do
  factory :log do
    category {Log::Categories.sample}

    trait :full_attributes do
      content {Faker::Lorem.sentence}
    end

    trait :form_input do
      content {Faker::Lorem.sentence}
    end

    ["album","artist","organization","song","source","event"].each do |model_name|
      trait("with_loglist_#{model_name}".to_sym) do
        after(:create) { |log| create(:loglist,"with_#{model_name}".to_sym, log: log )}
      end
    end

    trait :with_multiple_loglists do
      with_loglist_album
      with_loglist_artist
      with_loglist_organization
      with_loglist_song
      with_loglist_source
      with_loglist_event
    end

    trait(:invalid) {status {"wahahaha"}}
  end

  factory :loglist do
    association :log
    association :model, factory: :album

    ["album","artist","organization","song","source","event"].each do |model_name|
      trait("with_#{model_name}".to_sym) {association :model, factory: model_name}
    end
  end

end