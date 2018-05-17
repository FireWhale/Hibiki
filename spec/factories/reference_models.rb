# encoding: utf-8
require 'faker' 

FactoryBot.define do
  factory :reference do
    #Reequired Attributes
    site_name {Reference::SiteNames.sample}
    url { Faker::Internet.url }
    association :model, factory: :album
    
    ["artist", "album", "organization", "song", "source", "event", "user"].each do |model|
      trait("with_#{model}".to_sym) {association :model, factory: model.to_sym}
    end
  end
end