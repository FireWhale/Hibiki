# encoding: utf-8
require 'faker' 

FactoryGirl.define do
  factory :image do 
    #Required Attributes
    name {Faker::Lorem.word}
    path {Faker::Lorem.sentence}
    
    trait :full_attributes do
      primary_flag "Primary"
      rating { Image::Rating.sample}
      llimagelink {Faker::Lorem.sentence}
      thumb_path {Faker::Lorem.sentence}  
      medium_path {Faker::Lorem.sentence}
      height {Faker::Number.number(4)}
      width {Faker::Number.number(4)}
      medium_height {Faker::Number.number(4)}
      medium_width {Faker::Number.number(4)}
      thumb_height {Faker::Number.number(4)}
      thumb_width {Faker::Number.number(4)}
    end      
    
    trait :form_input do
      full_attributes
    end
    
    ["album", "artist", "organization", "source", "song", "user", "post", "season"].each do |model|
      trait "with_imagelist_#{model}".to_sym do
        after(:create) { |image| create(:imagelist,"with_#{model}".to_sym, image: image)}
      end        
    end
    
    trait :with_multiple_imagelists do
      with_imagelist_album
      with_imagelist_artist
      with_imagelist_organization
      with_imagelist_source
      with_imagelist_song
      with_imagelist_user
      with_imagelist_post
      with_imagelist_season
    end
    
    trait :invalid do
      path {""}
    end      
  end

  factory :imagelist do
    association :image
    association :model, factory: :album
    
    ["album", "artist", "organization", "source", "song", "user", "post", "season"]. each do |model|
      trait("with_#{model}".to_sym) {association :model, factory: model} 
    end            
  end
  
end