# encoding: utf-8
require 'faker' 

FactoryBot.define do
  factory :tag do
    #Required Attributes
    internal_name {Faker::Lorem.sentence}
    classification {Faker::Lorem.sentence}
    visibility {Ability::Abilities.sample}
    model_bitmask {Faker::Number.between(1,63)}
    
    trait :full_attributes do
      with_name_translations
      with_info_translations
    end
    
    trait :form_input do #Attributes that are passed by actual form input
      tag_models { Tag::ModelBitmask.sample(3) }
      model_bitmask nil
      
      name_form_attributes
      info_form_attributes
    end
    
    Tag::ModelBitmask.each do |model_name| #Taglist traits
      trait("with_taglist_#{model_name.downcase}".to_sym) do 
        after(:create) do |tag|
          #Edit the model_bitmask to allow the model we're adding
          tag.model_bitmask = Tag.get_bitmask(tag.models + [model_name]) unless tag.models.include?(model_name)
          
          create(:taglist, "with_#{model_name.downcase}".to_sym, tag: tag)
        end
      end
    end
    
    trait :with_multiple_taglists do
      with_taglist_album
      with_taglist_artist
      with_taglist_organization
      with_taglist_post
      with_taglist_song
      with_taglist_source
    end  
    
    trait(:invalid) {visibility "haha"}
  end
    
  factory :taglist do
    association :tag, model_bitmask: 63
    association :subject, factory: :album
    
    Tag::ModelBitmask.each do |model_name| #Taglist traits
      trait("with_#{model_name.downcase}".to_sym) {association :subject, factory: model_name.downcase.to_sym}
    end
  end    
    
end