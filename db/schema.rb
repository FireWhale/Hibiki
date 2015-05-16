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

ActiveRecord::Schema.define(version: 20150512225910) do

  create_table "album_events", force: :cascade do |t|
    t.integer  "album_id",   limit: 4
    t.integer  "event_id",   limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "album_events", ["album_id"], name: "index_album_events_on_album_id", using: :btree
  add_index "album_events", ["event_id"], name: "index_album_events_on_event_id", using: :btree

  create_table "album_organizations", force: :cascade do |t|
    t.integer  "album_id",        limit: 4
    t.integer  "organization_id", limit: 4
    t.string   "category",        limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "album_organizations", ["album_id"], name: "index_album_organizations_on_album_id", using: :btree
  add_index "album_organizations", ["category"], name: "index_album_organizations_on_category", using: :btree
  add_index "album_organizations", ["organization_id"], name: "index_album_organizations_on_organization_id", using: :btree

  create_table "album_sources", force: :cascade do |t|
    t.integer  "album_id",   limit: 4
    t.integer  "source_id",  limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "album_sources", ["album_id"], name: "index_album_sources_on_album_id", using: :btree
  add_index "album_sources", ["source_id"], name: "index_album_sources_on_source_id", using: :btree

  create_table "album_translations", force: :cascade do |t|
    t.integer  "album_id",   limit: 4,     null: false
    t.string   "locale",     limit: 255,   null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "name",       limit: 255
    t.text     "info",       limit: 65535
  end

  add_index "album_translations", ["album_id"], name: "index_album_translations_on_album_id", using: :btree
  add_index "album_translations", ["locale"], name: "index_album_translations_on_locale", using: :btree

  create_table "albums", force: :cascade do |t|
    t.string   "internal_name",        limit: 255
    t.string   "synonyms",             limit: 255
    t.string   "status",               limit: 255
    t.text     "info",                 limit: 65535
    t.text     "private_info",         limit: 65535
    t.text     "reference",            limit: 65535
    t.string   "classification",       limit: 255
    t.date     "release_date"
    t.string   "catalog_number",       limit: 255
    t.integer  "popularity",           limit: 4
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.text     "namehash",             limit: 65535
    t.integer  "release_date_bitmask", limit: 4
  end

  add_index "albums", ["catalog_number"], name: "index_albums_on_catalognumber", using: :btree
  add_index "albums", ["classification"], name: "index_albums_on_classification", using: :btree
  add_index "albums", ["internal_name"], name: "index_albums_on_internal_name", using: :btree
  add_index "albums", ["popularity"], name: "index_albums_on_popularity", using: :btree
  add_index "albums", ["release_date"], name: "index_albums_on_releasedate", using: :btree
  add_index "albums", ["status"], name: "index_albums_on_status", using: :btree
  add_index "albums", ["synonyms"], name: "index_albums_on_synonyms", using: :btree

  create_table "artist_albums", force: :cascade do |t|
    t.integer  "artist_id",  limit: 4
    t.integer  "album_id",   limit: 4
    t.string   "category",   limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "artist_albums", ["album_id"], name: "index_artist_albums_on_album_id", using: :btree
  add_index "artist_albums", ["artist_id"], name: "index_artist_albums_on_artist_id", using: :btree
  add_index "artist_albums", ["category"], name: "index_artist_albums_on_category", using: :btree

  create_table "artist_organizations", force: :cascade do |t|
    t.integer  "artist_id",       limit: 4
    t.integer  "organization_id", limit: 4
    t.string   "category",        limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "artist_organizations", ["artist_id"], name: "index_artist_organizations_on_artist_id", using: :btree
  add_index "artist_organizations", ["category"], name: "index_artist_organizations_on_category", using: :btree
  add_index "artist_organizations", ["organization_id"], name: "index_artist_organizations_on_organization_id", using: :btree

  create_table "artist_songs", force: :cascade do |t|
    t.integer  "artist_id",  limit: 4
    t.integer  "song_id",    limit: 4
    t.string   "category",   limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "artist_songs", ["artist_id"], name: "index_artist_songs_on_artist_id", using: :btree
  add_index "artist_songs", ["category"], name: "index_artist_songs_on_category", using: :btree
  add_index "artist_songs", ["song_id"], name: "index_artist_songs_on_song_id", using: :btree

  create_table "artist_translations", force: :cascade do |t|
    t.integer  "artist_id",  limit: 4,     null: false
    t.string   "locale",     limit: 255,   null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "name",       limit: 255
    t.text     "info",       limit: 65535
  end

  add_index "artist_translations", ["artist_id"], name: "index_artist_translations_on_artist_id", using: :btree
  add_index "artist_translations", ["locale"], name: "index_artist_translations_on_locale", using: :btree

  create_table "artists", force: :cascade do |t|
    t.string   "internal_name",      limit: 255
    t.string   "synonyms",           limit: 255
    t.string   "status",             limit: 255
    t.string   "db_status",          limit: 255
    t.string   "activity",           limit: 255
    t.string   "category",           limit: 255
    t.text     "info",               limit: 65535
    t.text     "private_info",       limit: 65535
    t.text     "synopsis",           limit: 65535
    t.text     "reference",          limit: 65535
    t.integer  "popularity",         limit: 4
    t.date     "debut_date"
    t.date     "birth_date"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.text     "namehash",           limit: 65535
    t.integer  "birth_date_bitmask", limit: 4
    t.string   "gender",             limit: 255
    t.string   "blood_type",         limit: 255
    t.string   "birth_place",        limit: 255
    t.integer  "debut_date_bitmask", limit: 4
  end

  add_index "artists", ["activity"], name: "index_artists_on_activity", using: :btree
  add_index "artists", ["birth_date"], name: "index_artists_on_birthdate", using: :btree
  add_index "artists", ["category"], name: "index_artists_on_category", using: :btree
  add_index "artists", ["db_status"], name: "index_artists_on_dbcomplete", using: :btree
  add_index "artists", ["debut_date"], name: "index_artists_on_debutdate", using: :btree
  add_index "artists", ["internal_name"], name: "index_artists_on_internal_name", using: :btree
  add_index "artists", ["popularity"], name: "index_artists_on_popularity", using: :btree
  add_index "artists", ["status"], name: "index_artists_on_status", using: :btree
  add_index "artists", ["synonyms"], name: "index_artists_on_synonyms", using: :btree

  create_table "collections", force: :cascade do |t|
    t.integer  "user_id",               limit: 4
    t.integer  "collected_id",          limit: 4
    t.integer  "rating",                limit: 4
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.string   "relationship",          limit: 255
    t.string   "collected_type",        limit: 255
    t.string   "user_comment",          limit: 255
    t.date     "date_obtained"
    t.integer  "date_obtained_bitmask", limit: 4
  end

  add_index "collections", ["collected_id"], name: "index_collections_on_collected_id", using: :btree
  add_index "collections", ["collected_type"], name: "index_collections_on_collected_type", using: :btree
  add_index "collections", ["rating"], name: "index_collections_on_rating", using: :btree
  add_index "collections", ["relationship"], name: "index_collections_on_relationship", using: :btree
  add_index "collections", ["user_id"], name: "index_collections_on_user_id", using: :btree

  create_table "events", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.date     "start_date"
    t.date     "end_date"
    t.string   "abbreviation", limit: 255
    t.text     "reference",    limit: 255
    t.text     "info",         limit: 65535
    t.string   "db_status",    limit: 255
    t.string   "altname",      limit: 255
    t.string   "shorthand",    limit: 255
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "events", ["abbreviation"], name: "index_events_on_abbreviation", using: :btree
  add_index "events", ["altname"], name: "index_events_on_altname", using: :btree
  add_index "events", ["db_status"], name: "index_events_on_db_status", using: :btree
  add_index "events", ["end_date"], name: "index_events_on_end_date", using: :btree
  add_index "events", ["shorthand"], name: "index_events_on_shorthand", using: :btree
  add_index "events", ["start_date"], name: "index_events_on_start_date", using: :btree

  create_table "imagelists", force: :cascade do |t|
    t.integer  "image_id",   limit: 4
    t.integer  "model_id",   limit: 4
    t.string   "model_type", limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "imagelists", ["image_id"], name: "index_imagelists_on_image_id", using: :btree
  add_index "imagelists", ["model_id"], name: "index_imagelists_on_model_id", using: :btree
  add_index "imagelists", ["model_type"], name: "index_imagelists_on_model_type", using: :btree

  create_table "images", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.string   "path",          limit: 255
    t.string   "primary_flag",  limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "rating",        limit: 255
    t.string   "llimagelink",   limit: 255
    t.string   "thumb_path",    limit: 255
    t.string   "medium_path",   limit: 255
    t.integer  "width",         limit: 4
    t.integer  "height",        limit: 4
    t.integer  "medium_width",  limit: 4
    t.integer  "medium_height", limit: 4
    t.integer  "thumb_width",   limit: 4
    t.integer  "thumb_height",  limit: 4
  end

  add_index "images", ["primary_flag"], name: "index_images_on_category", using: :btree
  add_index "images", ["rating"], name: "index_images_on_rating", using: :btree

  create_table "issues", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.string   "category",     limit: 255
    t.text     "description",  limit: 65535
    t.text     "private_info", limit: 65535
    t.string   "status",       limit: 255
    t.string   "priority",     limit: 255
    t.string   "visibility",   limit: 255
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "resolution",   limit: 255
    t.string   "difficulty",   limit: 255
  end

  add_index "issues", ["category"], name: "index_issues_on_category", using: :btree
  add_index "issues", ["created_at"], name: "index_issues_on_created_at", using: :btree
  add_index "issues", ["difficulty"], name: "index_issues_on_difficulty", using: :btree
  add_index "issues", ["priority"], name: "index_issues_on_priority", using: :btree
  add_index "issues", ["resolution"], name: "index_issues_on_resolution", using: :btree
  add_index "issues", ["status"], name: "index_issues_on_status", using: :btree
  add_index "issues", ["updated_at"], name: "index_issues_on_updated_at", using: :btree
  add_index "issues", ["visibility"], name: "index_issues_on_visibility", using: :btree

  create_table "lyrics", force: :cascade do |t|
    t.string   "language",   limit: 255
    t.integer  "song_id",    limit: 4
    t.text     "lyrics",     limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "lyrics", ["language"], name: "index_lyrics_on_language", using: :btree
  add_index "lyrics", ["song_id"], name: "index_lyrics_on_song_id", using: :btree

  create_table "organization_translations", force: :cascade do |t|
    t.integer  "organization_id", limit: 4,     null: false
    t.string   "locale",          limit: 255,   null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "name",            limit: 255
    t.text     "info",            limit: 65535
  end

  add_index "organization_translations", ["locale"], name: "index_organization_translations_on_locale", using: :btree
  add_index "organization_translations", ["organization_id"], name: "index_organization_translations_on_organization_id", using: :btree

  create_table "organizations", force: :cascade do |t|
    t.string   "internal_name",       limit: 255
    t.string   "synonyms",            limit: 255
    t.string   "status",              limit: 255
    t.string   "db_status",           limit: 255
    t.string   "activity",            limit: 255
    t.string   "category",            limit: 255
    t.text     "info",                limit: 65535
    t.text     "private_info",        limit: 65535
    t.text     "synopsis",            limit: 65535
    t.string   "reference",           limit: 255
    t.date     "established"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.text     "namehash",            limit: 65535
    t.integer  "established_bitmask", limit: 4
    t.integer  "popularity",          limit: 4
  end

  add_index "organizations", ["activity"], name: "index_organizations_on_activity", using: :btree
  add_index "organizations", ["category"], name: "index_organizations_on_category", using: :btree
  add_index "organizations", ["db_status"], name: "index_organizations_on_dbcomplete", using: :btree
  add_index "organizations", ["established"], name: "index_organizations_on_established", using: :btree
  add_index "organizations", ["internal_name"], name: "index_organizations_on_internal_name", using: :btree
  add_index "organizations", ["popularity"], name: "index_organizations_on_popularity", using: :btree
  add_index "organizations", ["status"], name: "index_organizations_on_status", using: :btree
  add_index "organizations", ["synonyms"], name: "index_organizations_on_synonyms", using: :btree

  create_table "postlists", force: :cascade do |t|
    t.integer  "post_id",    limit: 4
    t.integer  "model_id",   limit: 4
    t.string   "model_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "postlists", ["model_id"], name: "index_postlists_on_model_id", using: :btree
  add_index "postlists", ["model_type"], name: "index_postlists_on_model_type", using: :btree
  add_index "postlists", ["post_id"], name: "index_postlists_on_post_id", using: :btree

  create_table "posts", force: :cascade do |t|
    t.string   "category",   limit: 255
    t.binary   "content",    limit: 16777215
    t.string   "visibility", limit: 255
    t.datetime "timestamp"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "title",      limit: 255
    t.string   "status",     limit: 255
  end

  add_index "posts", ["category"], name: "index_posts_on_category", using: :btree
  add_index "posts", ["status"], name: "index_posts_on_status", using: :btree
  add_index "posts", ["visibility"], name: "index_posts_on_visibility", using: :btree

  create_table "related_albums", force: :cascade do |t|
    t.integer  "album1_id",  limit: 4
    t.integer  "album2_id",  limit: 4
    t.string   "category",   limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "related_albums", ["album1_id"], name: "index_related_albums_on_album1_id", using: :btree
  add_index "related_albums", ["album2_id"], name: "index_related_albums_on_album2_id", using: :btree
  add_index "related_albums", ["category"], name: "index_related_albums_on_category", using: :btree

  create_table "related_artists", force: :cascade do |t|
    t.integer  "artist1_id", limit: 4
    t.integer  "artist2_id", limit: 4
    t.string   "category",   limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "related_artists", ["artist1_id"], name: "index_related_artists_on_artist1_id", using: :btree
  add_index "related_artists", ["artist2_id"], name: "index_related_artists_on_artist2_id", using: :btree
  add_index "related_artists", ["category"], name: "index_related_artists_on_category", using: :btree

  create_table "related_organizations", force: :cascade do |t|
    t.integer  "organization1_id", limit: 4
    t.integer  "organization2_id", limit: 4
    t.string   "category",         limit: 255
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "related_organizations", ["category"], name: "index_related_organizations_on_category", using: :btree
  add_index "related_organizations", ["organization1_id"], name: "index_related_organizations_on_organization1_id", using: :btree
  add_index "related_organizations", ["organization2_id"], name: "index_related_organizations_on_organization2_id", using: :btree

  create_table "related_songs", force: :cascade do |t|
    t.integer  "song1_id",   limit: 4
    t.integer  "song2_id",   limit: 4
    t.string   "category",   limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "related_songs", ["category"], name: "index_related_songs_on_category", using: :btree
  add_index "related_songs", ["song1_id"], name: "index_related_songs_on_song1_id", using: :btree
  add_index "related_songs", ["song2_id"], name: "index_related_songs_on_song2_id", using: :btree

  create_table "related_sources", force: :cascade do |t|
    t.integer  "source1_id", limit: 4
    t.integer  "source2_id", limit: 4
    t.string   "category",   limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "related_sources", ["category"], name: "index_related_sources_on_category", using: :btree
  add_index "related_sources", ["source1_id"], name: "index_related_sources_on_source1_id", using: :btree
  add_index "related_sources", ["source2_id"], name: "index_related_sources_on_source2_id", using: :btree

  create_table "seasons", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.date     "start_date"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.date     "end_date"
  end

  add_index "seasons", ["end_date"], name: "index_seasons_on_end_date", using: :btree
  add_index "seasons", ["start_date"], name: "index_seasons_on_start_date", using: :btree

  create_table "song_sources", force: :cascade do |t|
    t.integer  "song_id",        limit: 4
    t.integer  "source_id",      limit: 4
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "classification", limit: 255
    t.string   "op_ed_number",   limit: 255
    t.string   "ep_numbers",     limit: 255
  end

  add_index "song_sources", ["classification"], name: "index_song_sources_on_classification", using: :btree
  add_index "song_sources", ["song_id"], name: "index_song_sources_on_song_id", using: :btree
  add_index "song_sources", ["source_id"], name: "index_song_sources_on_source_id", using: :btree

  create_table "song_translations", force: :cascade do |t|
    t.integer  "song_id",    limit: 4,     null: false
    t.string   "locale",     limit: 255,   null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "name",       limit: 255
    t.text     "info",       limit: 65535
    t.text     "lyrics",     limit: 65535
  end

  add_index "song_translations", ["locale"], name: "index_song_translations_on_locale", using: :btree
  add_index "song_translations", ["song_id"], name: "index_song_translations_on_song_id", using: :btree

  create_table "songs", force: :cascade do |t|
    t.string   "internal_name",        limit: 255
    t.text     "namehash",             limit: 65535
    t.integer  "album_id",             limit: 4
    t.string   "track_number",         limit: 255
    t.integer  "length",               limit: 4
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.text     "reference",            limit: 65535
    t.text     "info",                 limit: 65535
    t.text     "private_info",         limit: 65535
    t.date     "release_date"
    t.integer  "release_date_bitmask", limit: 4
    t.string   "synonyms",             limit: 255
    t.string   "status",               limit: 255
    t.string   "disc_number",          limit: 255
  end

  add_index "songs", ["album_id"], name: "index_songs_on_album_id", using: :btree
  add_index "songs", ["disc_number"], name: "index_songs_on_disc_number", using: :btree
  add_index "songs", ["internal_name"], name: "index_songs_on_internal_name", using: :btree
  add_index "songs", ["release_date"], name: "index_songs_on_release_date", using: :btree
  add_index "songs", ["status"], name: "index_songs_on_status", using: :btree
  add_index "songs", ["synonyms"], name: "index_songs_on_synonyms", using: :btree
  add_index "songs", ["track_number"], name: "index_songs_on_track_number", using: :btree

  create_table "source_organizations", force: :cascade do |t|
    t.integer  "source_id",       limit: 4
    t.integer  "organization_id", limit: 4
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "category",        limit: 255
  end

  add_index "source_organizations", ["category"], name: "index_source_organizations_on_category", using: :btree
  add_index "source_organizations", ["organization_id"], name: "index_source_organizations_on_organization_id", using: :btree
  add_index "source_organizations", ["source_id"], name: "index_source_organizations_on_source_id", using: :btree

  create_table "source_seasons", force: :cascade do |t|
    t.integer  "source_id",  limit: 4
    t.integer  "season_id",  limit: 4
    t.string   "category",   limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "source_seasons", ["category"], name: "index_source_seasons_on_category", using: :btree
  add_index "source_seasons", ["season_id"], name: "index_source_seasons_on_season_id", using: :btree
  add_index "source_seasons", ["source_id"], name: "index_source_seasons_on_source_id", using: :btree

  create_table "source_translations", force: :cascade do |t|
    t.integer  "source_id",  limit: 4,     null: false
    t.string   "locale",     limit: 255,   null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "name",       limit: 1000
    t.text     "info",       limit: 65535
  end

  add_index "source_translations", ["locale"], name: "index_source_translations_on_locale", using: :btree
  add_index "source_translations", ["source_id"], name: "index_source_translations_on_source_id", using: :btree

  create_table "sources", force: :cascade do |t|
    t.string   "internal_name",        limit: 1000
    t.string   "synonyms",             limit: 255
    t.string   "status",               limit: 255
    t.string   "db_status",            limit: 255
    t.string   "activity",             limit: 255
    t.string   "category",             limit: 255
    t.text     "info",                 limit: 65535
    t.text     "private_info",         limit: 65535
    t.text     "synopsis",             limit: 65535
    t.text     "reference",            limit: 65535
    t.integer  "popularity",           limit: 4
    t.date     "release_date"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.text     "namehash",             limit: 65535
    t.date     "end_date"
    t.integer  "release_date_bitmask", limit: 4
    t.integer  "end_date_bitmask",     limit: 4
    t.text     "plot_summary",         limit: 65535
  end

  add_index "sources", ["activity"], name: "index_sources_on_activity", using: :btree
  add_index "sources", ["category"], name: "index_sources_on_category", using: :btree
  add_index "sources", ["db_status"], name: "index_sources_on_dbcomplete", using: :btree
  add_index "sources", ["end_date"], name: "index_sources_on_end_date", using: :btree
  add_index "sources", ["internal_name"], name: "index_sources_on_internal_name", length: {"internal_name"=>255}, using: :btree
  add_index "sources", ["popularity"], name: "index_sources_on_popularity", using: :btree
  add_index "sources", ["release_date"], name: "index_sources_on_releasedate", using: :btree
  add_index "sources", ["status"], name: "index_sources_on_status", using: :btree
  add_index "sources", ["synonyms"], name: "index_sources_on_synonyms", using: :btree

  create_table "taglists", force: :cascade do |t|
    t.integer  "tag_id",       limit: 4
    t.integer  "subject_id",   limit: 4
    t.string   "subject_type", limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "taglists", ["subject_id"], name: "index_taglists_on_subject_id", using: :btree
  add_index "taglists", ["subject_type"], name: "index_taglists_on_subject_type", using: :btree
  add_index "taglists", ["tag_id"], name: "index_taglists_on_tag_id", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.string   "classification", limit: 255
    t.text     "info",           limit: 65535
    t.text     "synopsis",       limit: 65535
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "model_bitmask",  limit: 4
    t.string   "visibility",     limit: 255
  end

  add_index "tags", ["classification"], name: "index_tags_on_category", using: :btree
  add_index "tags", ["name"], name: "index_tags_on_name", using: :btree
  add_index "tags", ["visibility"], name: "index_tags_on_visibility", using: :btree

  create_table "user_sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "name",                     limit: 255
    t.string   "email",                    limit: 255
    t.text     "profile",                  limit: 65535
    t.date     "birth_date"
    t.string   "sex",                      limit: 255
    t.string   "location",                 limit: 255
    t.string   "crypted_password",         limit: 255
    t.string   "password_salt",            limit: 255
    t.string   "persistence_token",        limit: 255
    t.integer  "login_count",              limit: 4,     default: 0,  null: false
    t.integer  "failed_login_count",       limit: 4,     default: 0,  null: false
    t.datetime "last_request_at"
    t.datetime "last_login_at"
    t.string   "privacy",                  limit: 255
    t.string   "security",                 limit: 255
    t.string   "stylesheet",               limit: 255
    t.text     "usernames",                limit: 65535
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.integer  "display_bitmask",          limit: 4
    t.string   "language_settings",        limit: 255
    t.string   "artist_language_settings", limit: 255
    t.integer  "tracklist_export_bitmask", limit: 4
    t.string   "perishable_token",         limit: 255,   default: "", null: false
    t.integer  "birth_date_bitmask",       limit: 4
  end

  add_index "users", ["created_at"], name: "index_users_on_created_at", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["location"], name: "index_users_on_location", using: :btree
  add_index "users", ["name"], name: "index_users_on_name", using: :btree
  add_index "users", ["stylesheet"], name: "index_users_on_stylesheet", using: :btree

  create_table "watchlists", force: :cascade do |t|
    t.integer  "user_id",           limit: 4
    t.integer  "watched_id",        limit: 4
    t.string   "watched_type",      limit: 255
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.integer  "position",          limit: 4
    t.string   "grouping_category", limit: 255
  end

  add_index "watchlists", ["grouping_category"], name: "index_watchlists_on_grouping_category", using: :btree
  add_index "watchlists", ["position"], name: "index_watchlists_on_position", using: :btree
  add_index "watchlists", ["user_id"], name: "index_watchlists_on_user_id", using: :btree
  add_index "watchlists", ["watched_id"], name: "index_watchlists_on_watched_id", using: :btree
  add_index "watchlists", ["watched_type"], name: "index_watchlists_on_watched_type", using: :btree

end
