# encoding: utf-8
require 'faker' 

FactoryGirl.define do
  #Primary Models - Albums, Artists, Organizations, Sources, Songs
    factory :album do    
      name {Faker::Lorem.sentence}
      status {Album::Status.sample}
      namehash {{"English" => "hi", 
        "Spanish" => "hola",
        "Romaji" => "konnichiwa",
        "Japanese" => "こんにいちは",
        "Hangul" => "안녕하세요",
        "Romanized Korean" => "annyeonghaseyo",
        Faker::Lorem.word => Faker::Lorem.word}}
      catalog_number {Faker::Lorem.word}
    end
    
    factory :artist do 
      name {Faker::Name.name}
      status {Album::Status.sample}
    end
    
    factory :organization do 
      name {Faker::Lorem.sentence}
      status {Album::Status.sample}
    end
    
    factory :source do 
      name {Faker::Lorem.sentence}
      status {Album::Status.sample}
    end
    
    factory :song do 
      name {Faker::Lorem.sentence}
      
    end
end