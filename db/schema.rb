# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150319211947) do

  create_table "album_events", force: true do |t|
    t.integer  "album_id"
    t.integer  "event_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "album_events", ["album_id"], name: "index_album_events_on_album_id", using: :btree
  add_index "album_events", ["event_id"], name: "index_album_events_on_event_id", using: :btree

  create_table "album_organizations", force: true do |t|
    t.integer  "album_id"
    t.integer  "organization_id"
    t.string   "category"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "album_organizations", ["album_id"], name: "index_album_organizations_on_album_id", using: :btree
  add_index "album_organizations", ["category"], name: "index_album_organizations_on_category", using: :btree
  add_index "album_organizations", ["organization_id"], name: "index_album_organizations_on_organization_id", using: :btree

  create_table "album_sources", force: true do |t|
    t.integer  "album_id"
    t.integer  "source_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "album_sources", ["album_id"], name: "index_album_sources_on_album_id", using: :btree
  add_index "album_sources", ["source_id"], name: "index_album_sources_on_source_id", using: :btree

  create_table "albums", force: true do |t|
    t.string   "name"
    t.string   "altname"
    t.string   "status"
    t.text     "info"
    t.text     "private_info"
    t.text     "reference"
    t.string   "classification"
    t.date     "release_date"
    t.string   "catalog_number"
    t.integer  "popularity"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.text     "namehash"
    t.integer  "release_date_bitmask"
  end

  add_index "albums", ["altname"], name: "index_albums_on_altname", using: :btree
  add_index "albums", ["catalog_number"], name: "index_albums_on_catalognumber", using: :btree
  add_index "albums", ["classification"], name: "index_albums_on_classification", using: :btree
  add_index "albums", ["name"], name: "index_albums_on_name", using: :btree
  add_index "albums", ["popularity"], name: "index_albums_on_popularity", using: :btree
  add_index "albums", ["release_date"], name: "index_albums_on_releasedate", using: :btree
  add_index "albums", ["status"], name: "index_albums_on_status", using: :btree

  create_table "artist_albums", force: true do |t|
    t.integer  "artist_id"
    t.integer  "album_id"
    t.string   "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "artist_albums", ["album_id"], name: "index_artist_albums_on_album_id", using: :btree
  add_index "artist_albums", ["artist_id"], name: "index_artist_albums_on_artist_id", using: :btree
  add_index "artist_albums", ["category"], name: "index_artist_albums_on_category", using: :btree

  create_table "artist_organizations", force: true do |t|
    t.integer  "artist_id"
    t.integer  "organization_id"
    t.string   "category"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "artist_organizations", ["artist_id"], name: "index_artist_organizations_on_artist_id", using: :btree
  add_index "artist_organizations", ["category"], name: "index_artist_organizations_on_category", using: :btree
  add_index "artist_organizations", ["organization_id"], name: "index_artist_organizations_on_organization_id", using: :btree

  create_table "artist_songs", force: true do |t|
    t.integer  "artist_id"
    t.integer  "song_id"
    t.string   "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "artist_songs", ["artist_id"], name: "index_artist_songs_on_artist_id", using: :btree
  add_index "artist_songs", ["category"], name: "index_artist_songs_on_category", using: :btree
  add_index "artist_songs", ["song_id"], name: "index_artist_songs_on_song_id", using: :btree

  create_table "artists", force: true do |t|
    t.string   "name"
    t.string   "altname"
    t.string   "status"
    t.string   "db_status"
    t.string   "activity"
    t.string   "category"
    t.text     "info"
    t.text     "private_info"
    t.text     "synopsis"
    t.text     "reference"
    t.integer  "popularity"
    t.date     "debut_date"
    t.date     "birth_date"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.text     "namehash"
    t.integer  "birth_date_bitmask"
    t.string   "gender"
    t.string   "blood_type"
    t.string   "birth_place"
    t.integer  "debut_date_bitmask"
  end

  add_index "artists", ["activity"], name: "index_artists_on_activity", using: :btree
  add_index "artists", ["altname"], name: "index_artists_on_altname", using: :btree
  add_index "artists", ["birth_date"], name: "index_artists_on_birthdate", using: :btree
  add_index "artists", ["category"], name: "index_artists_on_category", using: :btree
  add_index "artists", ["db_status"], name: "index_artists_on_dbcomplete", using: :btree
  add_index "artists", ["debut_date"], name: "index_artists_on_debutdate", using: :btree
  add_index "artists", ["name"], name: "index_artists_on_name", using: :btree
  add_index "artists", ["popularity"], name: "index_artists_on_popularity", using: :btree
  add_index "artists", ["status"], name: "index_artists_on_status", using: :btree

  create_table "collections", force: true do |t|
    t.integer  "user_id"
    t.integer  "album_id"
    t.integer  "rating"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "relationship"
  end

  add_index "collections", ["album_id"], name: "index_collections_on_album_id", using: :btree
  add_index "collections", ["rating"], name: "index_collections_on_rating", using: :btree
  add_index "collections", ["relationship"], name: "index_collections_on_relationship", using: :btree
  add_index "collections", ["user_id"], name: "index_collections_on_user_id", using: :btree

  create_table "events", force: true do |t|
    t.string   "name"
    t.date     "start_date"
    t.date     "end_date"
    t.string   "abbreviation"
    t.text     "reference",    limit: 255
    t.text     "info"
    t.string   "db_status"
    t.string   "altname"
    t.string   "shorthand"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "events", ["abbreviation"], name: "index_events_on_abbreviation", using: :btree
  add_index "events", ["altname"], name: "index_events_on_altname", using: :btree
  add_index "events", ["db_status"], name: "index_events_on_db_status", using: :btree
  add_index "events", ["end_date"], name: "index_events_on_end_date", using: :btree
  add_index "events", ["shorthand"], name: "index_events_on_shorthand", using: :btree
  add_index "events", ["start_date"], name: "index_events_on_start_date", using: :btree

  create_table "imagelists", force: true do |t|
    t.integer  "image_id"
    t.integer  "model_id"
    t.string   "model_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "imagelists", ["image_id"], name: "index_imagelists_on_image_id", using: :btree
  add_index "imagelists", ["model_id"], name: "index_imagelists_on_model_id", using: :btree
  add_index "imagelists", ["model_type"], name: "index_imagelists_on_model_type", using: :btree

  create_table "images", force: true do |t|
    t.string   "name"
    t.string   "path"
    t.string   "primary_flag"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "rating"
    t.string   "llimagelink"
    t.string   "thumb_path"
    t.string   "medium_path"
    t.integer  "width"
    t.integer  "height"
    t.integer  "medium_width"
    t.integer  "medium_height"
    t.integer  "thumb_width"
    t.integer  "thumb_height"
  end

  add_index "images", ["primary_flag"], name: "index_images_on_category", using: :btree
  add_index "images", ["rating"], name: "index_images_on_rating", using: :btree

  create_table "issue_users", force: true do |t|
    t.integer  "issue_id"
    t.integer  "user_id"
    t.text     "comment"
    t.string   "vote"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "issue_users", ["issue_id"], name: "index_issue_users_on_issue_id", using: :btree
  add_index "issue_users", ["user_id"], name: "index_issue_users_on_user_id", using: :btree

  create_table "issues", force: true do |t|
    t.string   "name"
    t.string   "category"
    t.text     "description"
    t.text     "private_info"
    t.string   "status"
    t.string   "priority"
    t.string   "visibility"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "resolution"
    t.string   "difficulty"
  end

  add_index "issues", ["category"], name: "index_issues_on_category", using: :btree
  add_index "issues", ["created_at"], name: "index_issues_on_created_at", using: :btree
  add_index "issues", ["difficulty"], name: "index_issues_on_difficulty", using: :btree
  add_index "issues", ["priority"], name: "index_issues_on_priority", using: :btree
  add_index "issues", ["resolution"], name: "index_issues_on_resolution", using: :btree
  add_index "issues", ["status"], name: "index_issues_on_status", using: :btree
  add_index "issues", ["updated_at"], name: "index_issues_on_updated_at", using: :btree
  add_index "issues", ["visibility"], name: "index_issues_on_visibility", using: :btree

  create_table "lyrics", force: true do |t|
    t.string   "language"
    t.integer  "song_id"
    t.text     "lyrics"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "lyrics", ["language"], name: "index_lyrics_on_language", using: :btree
  add_index "lyrics", ["song_id"], name: "index_lyrics_on_song_id", using: :btree

  create_table "organizations", force: true do |t|
    t.string   "name"
    t.string   "altname"
    t.string   "status"
    t.string   "db_status"
    t.string   "activity"
    t.string   "category"
    t.text     "info"
    t.text     "private_info"
    t.text     "synopsis"
    t.string   "reference"
    t.date     "established"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.text     "namehash"
    t.integer  "established_bitmask"
    t.integer  "popularity"
  end

  add_index "organizations", ["activity"], name: "index_organizations_on_activity", using: :btree
  add_index "organizations", ["altname"], name: "index_organizations_on_altname", using: :btree
  add_index "organizations", ["category"], name: "index_organizations_on_category", using: :btree
  add_index "organizations", ["db_status"], name: "index_organizations_on_dbcomplete", using: :btree
  add_index "organizations", ["established"], name: "index_organizations_on_established", using: :btree
  add_index "organizations", ["name"], name: "index_organizations_on_name", using: :btree
  add_index "organizations", ["popularity"], name: "index_organizations_on_popularity", using: :btree
  add_index "organizations", ["status"], name: "index_organizations_on_status", using: :btree

  create_table "postlists", force: true do |t|
    t.integer  "post_id"
    t.integer  "model_id"
    t.string   "model_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "postlists", ["model_id"], name: "index_postlists_on_model_id", using: :btree
  add_index "postlists", ["model_type"], name: "index_postlists_on_model_type", using: :btree
  add_index "postlists", ["post_id"], name: "index_postlists_on_post_id", using: :btree

  create_table "posts", force: true do |t|
    t.string   "category"
    t.binary   "content",      limit: 16777215
    t.integer  "user_id"
    t.string   "visibility"
    t.integer  "recipient_id"
    t.string   "user_info"
    t.datetime "timestamp"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "title"
    t.string   "status"
  end

  add_index "posts", ["category"], name: "index_posts_on_category", using: :btree
  add_index "posts", ["recipient_id"], name: "index_posts_on_recipient_id", using: :btree
  add_index "posts", ["status"], name: "index_posts_on_status", using: :btree
  add_index "posts", ["user_id"], name: "index_posts_on_user_id", using: :btree
  add_index "posts", ["visibility"], name: "index_posts_on_visibility", using: :btree

  create_table "ratings", force: true do |t|
    t.integer  "user_id"
    t.string   "song_id"
    t.integer  "rating"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "favorite"
  end

  add_index "ratings", ["favorite"], name: "index_ratings_on_favorite", using: :btree
  add_index "ratings", ["rating"], name: "index_ratings_on_rating", using: :btree
  add_index "ratings", ["song_id"], name: "index_ratings_on_song_id", using: :btree
  add_index "ratings", ["user_id"], name: "index_ratings_on_user_id", using: :btree

  create_table "related_albums", force: true do |t|
    t.integer  "album1_id"
    t.integer  "album2_id"
    t.string   "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "related_albums", ["album1_id"], name: "index_related_albums_on_album1_id", using: :btree
  add_index "related_albums", ["album2_id"], name: "index_related_albums_on_album2_id", using: :btree
  add_index "related_albums", ["category"], name: "index_related_albums_on_category", using: :btree

  create_table "related_artists", force: true do |t|
    t.integer  "artist1_id"
    t.integer  "artist2_id"
    t.string   "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "related_artists", ["artist1_id"], name: "index_related_artists_on_artist1_id", using: :btree
  add_index "related_artists", ["artist2_id"], name: "index_related_artists_on_artist2_id", using: :btree
  add_index "related_artists", ["category"], name: "index_related_artists_on_category", using: :btree

  create_table "related_organizations", force: true do |t|
    t.integer  "organization1_id"
    t.integer  "organization2_id"
    t.string   "category"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "related_organizations", ["category"], name: "index_related_organizations_on_category", using: :btree
  add_index "related_organizations", ["organization1_id"], name: "index_related_organizations_on_organization1_id", using: :btree
  add_index "related_organizations", ["organization2_id"], name: "index_related_organizations_on_organization2_id", using: :btree

  create_table "related_songs", force: true do |t|
    t.integer  "song1_id"
    t.integer  "song2_id"
    t.string   "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "related_songs", ["category"], name: "index_related_songs_on_category", using: :btree
  add_index "related_songs", ["song1_id"], name: "index_related_songs_on_song1_id", using: :btree
  add_index "related_songs", ["song2_id"], name: "index_related_songs_on_song2_id", using: :btree

  create_table "related_sources", force: true do |t|
    t.integer  "source1_id"
    t.integer  "source2_id"
    t.string   "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "related_sources", ["category"], name: "index_related_sources_on_category", using: :btree
  add_index "related_sources", ["source1_id"], name: "index_related_sources_on_source1_id", using: :btree
  add_index "related_sources", ["source2_id"], name: "index_related_sources_on_source2_id", using: :btree

  create_table "seasons", force: true do |t|
    t.string   "name"
    t.date     "start_date"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.date     "end_date"
    t.integer  "start_date_bitmask"
    t.integer  "end_date_bitmask"
  end

  add_index "seasons", ["end_date"], name: "index_seasons_on_end_date", using: :btree
  add_index "seasons", ["start_date"], name: "index_seasons_on_start_date", using: :btree

  create_table "song_sources", force: true do |t|
    t.integer  "song_id"
    t.integer  "source_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "classification"
    t.string   "op_ed_number"
    t.string   "ep_numbers"
  end

  add_index "song_sources", ["classification"], name: "index_song_sources_on_classification", using: :btree
  add_index "song_sources", ["song_id"], name: "index_song_sources_on_song_id", using: :btree
  add_index "song_sources", ["source_id"], name: "index_song_sources_on_source_id", using: :btree

  create_table "songs", force: true do |t|
    t.string   "name"
    t.text     "namehash"
    t.integer  "album_id"
    t.string   "track_number"
    t.integer  "length"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.text     "reference"
    t.text     "info"
    t.text     "private_info"
    t.date     "release_date"
    t.integer  "release_date_bitmask"
    t.string   "altname"
    t.string   "status"
    t.string   "disc_number"
  end

  add_index "songs", ["album_id"], name: "index_songs_on_album_id", using: :btree
  add_index "songs", ["altname"], name: "index_songs_on_altname", using: :btree
  add_index "songs", ["disc_number"], name: "index_songs_on_disc_number", using: :btree
  add_index "songs", ["name"], name: "index_songs_on_name", using: :btree
  add_index "songs", ["release_date"], name: "index_songs_on_release_date", using: :btree
  add_index "songs", ["status"], name: "index_songs_on_status", using: :btree
  add_index "songs", ["track_number"], name: "index_songs_on_track_number", using: :btree

  create_table "source_organizations", force: true do |t|
    t.integer  "source_id"
    t.integer  "organization_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "category"
  end

  add_index "source_organizations", ["category"], name: "index_source_organizations_on_category", using: :btree
  add_index "source_organizations", ["organization_id"], name: "index_source_organizations_on_organization_id", using: :btree
  add_index "source_organizations", ["source_id"], name: "index_source_organizations_on_source_id", using: :btree

  create_table "source_seasons", force: true do |t|
    t.integer  "source_id"
    t.integer  "season_id"
    t.string   "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "source_seasons", ["category"], name: "index_source_seasons_on_category", using: :btree
  add_index "source_seasons", ["season_id"], name: "index_source_seasons_on_season_id", using: :btree
  add_index "source_seasons", ["source_id"], name: "index_source_seasons_on_source_id", using: :btree

  create_table "sources", force: true do |t|
    t.string   "name",                 limit: 1000
    t.string   "altname"
    t.string   "status"
    t.string   "db_status"
    t.string   "activity"
    t.string   "category"
    t.text     "info"
    t.text     "private_info"
    t.text     "synopsis"
    t.text     "reference"
    t.integer  "popularity"
    t.date     "release_date"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.text     "namehash"
    t.date     "end_date"
    t.integer  "release_date_bitmask"
    t.integer  "end_date_bitmask"
    t.text     "plot_summary"
  end

  add_index "sources", ["activity"], name: "index_sources_on_activity", using: :btree
  add_index "sources", ["altname"], name: "index_sources_on_altname", using: :btree
  add_index "sources", ["category"], name: "index_sources_on_category", using: :btree
  add_index "sources", ["db_status"], name: "index_sources_on_dbcomplete", using: :btree
  add_index "sources", ["end_date"], name: "index_sources_on_end_date", using: :btree
  add_index "sources", ["name"], name: "index_sources_on_name", length: {"name"=>255}, using: :btree
  add_index "sources", ["popularity"], name: "index_sources_on_popularity", using: :btree
  add_index "sources", ["release_date"], name: "index_sources_on_releasedate", using: :btree
  add_index "sources", ["status"], name: "index_sources_on_status", using: :btree

  create_table "taglists", force: true do |t|
    t.integer  "tag_id"
    t.integer  "subject_id"
    t.string   "subject_type"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "taglists", ["subject_id"], name: "index_taglists_on_subject_id", using: :btree
  add_index "taglists", ["subject_type"], name: "index_taglists_on_subject_type", using: :btree
  add_index "taglists", ["tag_id"], name: "index_taglists_on_tag_id", using: :btree

  create_table "tags", force: true do |t|
    t.string   "name"
    t.string   "classification"
    t.text     "info"
    t.text     "synopsis"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "model_bitmask"
    t.string   "visibility"
  end

  add_index "tags", ["classification"], name: "index_tags_on_category", using: :btree
  add_index "tags", ["name"], name: "index_tags_on_name", using: :btree
  add_index "tags", ["visibility"], name: "index_tags_on_visibility", using: :btree

  create_table "user_sessions", force: true do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.text     "profile"
    t.date     "birth_date"
    t.string   "sex"
    t.string   "location"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token"
    t.integer  "login_count",              default: 0,  null: false
    t.integer  "failed_login_count",       default: 0,  null: false
    t.datetime "last_request_at"
    t.datetime "last_login_at"
    t.string   "privacy"
    t.string   "security"
    t.string   "stylesheet"
    t.text     "usernames"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "display_bitmask"
    t.string   "language_settings"
    t.string   "artist_language_settings"
    t.integer  "tracklist_export_bitmask"
    t.string   "perishable_token",         default: "", null: false
    t.integer  "birth_date_bitmask"
  end

  add_index "users", ["created_at"], name: "index_users_on_created_at", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["location"], name: "index_users_on_location", using: :btree
  add_index "users", ["name"], name: "index_users_on_name", using: :btree
  add_index "users", ["stylesheet"], name: "index_users_on_stylesheet", using: :btree

  create_table "watchlists", force: true do |t|
    t.integer  "user_id"
    t.integer  "watched_id"
    t.string   "watched_type"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "position"
    t.string   "grouping_category"
  end

  add_index "watchlists", ["grouping_category"], name: "index_watchlists_on_grouping_category", using: :btree
  add_index "watchlists", ["position"], name: "index_watchlists_on_position", using: :btree
  add_index "watchlists", ["user_id"], name: "index_watchlists_on_user_id", using: :btree
  add_index "watchlists", ["watched_id"], name: "index_watchlists_on_watched_id", using: :btree
  add_index "watchlists", ["watched_type"], name: "index_watchlists_on_watched_type", using: :btree

end
