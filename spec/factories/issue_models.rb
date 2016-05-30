# encoding: utf-8
require 'faker' 

FactoryGirl.define do
  factory :issue do
    name {Faker::Lorem.sentence}
    category {Issue::Categories.sample}
    visibility {Ability::Abilities.sample}
    status {Issue::Status.sample}
             
    trait :full_attributes do
      priority {Issue::Priorities.sample}
      difficulty {Issue::Difficulties.sample}
      resolution {Issue::Resolutions.sample}
      description { Faker::Lorem.sentence }
      private_info { Faker::Lorem.sentence }
    end

    trait(:form_input) {full_attributes} #Nothing extra in forms 

    trait(:admin_only) {visibility "Admin" }
        
    trait(:invalid) {status {"eife"}}
  end
end