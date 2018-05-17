# encoding: utf-8
require 'faker' 

FactoryBot.define do
  factory :post do
    category "Rescrape Result"
    visibility {Ability::Abilities.sample}
    status {Post::Status.sample}

    trait :full_attributes do
      title {Faker::Lorem.word}
      content {Faker::Lorem.sentence}
      timestamp {Faker::Date.between(1.year.ago, Date.today)} 
    end
    
    trait :form_input do
      title {Faker::Lorem.word}
      content {Faker::Lorem.sentence}
      image_form_attributes
    end
    
    ["album","artist","organization","song","source"].each do |model_name|
      trait("with_postlist_#{model_name}".to_sym) do
        after(:create) { |post| create(:postlist,"with_#{model_name}".to_sym, post: post )}
      end
    end
    
    trait :with_multiple_postlists do
      with_postlist_album
      with_postlist_artist
      with_postlist_organization
      with_postlist_song
      with_postlist_source      
    end     
        
    trait(:invalid) {status {"wahahaha"}}
  end
  
  factory :postlist do
    association :post
    association :model, factory: :album

    ["album","artist","organization","song","source"].each do |model_name|
      trait("with_#{model_name}".to_sym) {association :model, factory: model_name}
    end
  end
  
end