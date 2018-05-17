# encoding: utf-8
require 'faker'

FactoryBot.define do
  factory :song do
    #Required Attributes
    internal_name {Faker::Lorem.sentence}
    status {Album::Status.sample}

    trait :with_other_attributes do #Just to cut down on repetition on the following traits
      synonyms {Faker::Lorem.sentence}
      track_number { "15"}
      disc_number { "5" }
      namehash {{:haha => "hoho"}}
      length {Faker::Number.number(3)}
      info {Faker::Lorem.sentence}
      private_info {Faker::Lorem.sentence}
      lyrics {Faker::Lorem.sentence}
      release_date {Faker::Date.between(2.years.ago, Date.today)}
    end

    trait :full_attributes do
      with_other_attributes

      with_album
      release_date_bitmask { 6 }
      with_name_translations
      with_info_translations
      with_lyrics_translations
    end

    trait :form_input do
      with_other_attributes

      reference_form_attributes
      image_form_attributes
      info_form_attributes
      lyrics_form_attributes
      name_form_attributes

      new_related_songs {{:id => ["1", "2"], :category => ["Same Song", "Arrangement"]}}
      remove_related_songs ["3"]
      update_related_songs { {"4" => {:category => "Same Song"}, "2" => {:category => "Arrangment"}} }

      new_artists {{:id => ["5", "4"], :category =>  (Artist::Credits.sample(2) + ["New Artist"] + Artist::Credits.sample(2))}}
      update_artist_songs {{"5" => {:category => Artist::Credits.sample(4)}, "3" => {:category => []}}} #empty array will trigger destroy

      new_sources {{:id => ["1","2"], :classification => ["OP", "ED"],
                    :op_ed_number => ["5", "3"], :ep_numbers => ["5-6", "2-3"]}}
      remove_song_sources ["5"]
      update_source_seasons {{"1" => {:classification => "ED", :op_ed_number => "232", :ep_numbers => "2-5"}}}
    end

    trait :with_album do
      association :album
    end

    trait :with_self_relation do
      after(:create) do |record|
        create(:related_songs, song1: record)
        create(:related_songs, song2: record)
      end
    end

    trait :with_primary_relations do
      after(:create) do |record|
        create(:artist_song, song: record)
        create(:song_source, song: record)
      end
    end

    trait :invalid do
      internal_name ""
    end
  end
end