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

ActiveRecord::Schema.define(version: 20170603064734) do

  create_table "abouts", force: :cascade do |t|
    t.text     "description", limit: 16777215
    t.integer  "event_id",    limit: 4
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.text     "address",     limit: 16777215
  end

  add_index "abouts", ["event_id"], name: "index_abouts_on_event_id", using: :btree

  create_table "agenda_speakers", force: :cascade do |t|
    t.integer  "agenda_id",    limit: 4
    t.integer  "speaker_id",   limit: 4
    t.string   "speaker_name", limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "agenda_tracks", force: :cascade do |t|
    t.string   "track_name",  limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "event_id",    limit: 4
    t.integer  "sequence",    limit: 4
    t.date     "agenda_date"
    t.integer  "parent_id",   limit: 4
  end

  add_index "agenda_tracks", ["id"], name: "index_agenda_tracks_on_id", using: :btree
  add_index "agenda_tracks", ["parent_id"], name: "index_agenda_tracks_on_parent_id", using: :btree
  add_index "agenda_tracks", ["track_name"], name: "index_track_name_in_agenda_tracks", length: {"track_name"=>191}, using: :btree

  create_table "agendas", force: :cascade do |t|
    t.string   "event_name",              limit: 255
    t.string   "event_time",              limit: 255
    t.string   "speaker_name",            limit: 255
    t.string   "options",                 limit: 255
    t.integer  "event_id",                limit: 4
    t.datetime "created_at",                                                  null: false
    t.datetime "updated_at",                                                  null: false
    t.text     "discription",             limit: 16777215
    t.datetime "agenda_date"
    t.datetime "start_agenda_time"
    t.datetime "end_agenda_time"
    t.text     "title",                   limit: 16777215
    t.integer  "speaker_id",              limit: 4
    t.datetime "start_agenda_date"
    t.datetime "end_agenda_date"
    t.string   "rating_status",           limit: 255,      default: "active"
    t.string   "agenda_type",             limit: 255
    t.integer  "sequence",                limit: 4
    t.string   "event_timezone",          limit: 255
    t.integer  "agenda_track_id",         limit: 4
    t.datetime "old_start_agenda_time"
    t.datetime "old_start_agenda_date"
    t.datetime "old_end_agenda_date"
    t.datetime "old_end_agenda_time"
    t.integer  "parent_id",               limit: 4
    t.string   "event_timezone_offset",   limit: 255
    t.string   "event_display_time_zone", limit: 255
    t.string   "speaker_ids",             limit: 255
    t.string   "speaker_names",           limit: 255
    t.text     "all_speaker_names",       limit: 65535
    t.integer  "ratings_count_cache",     limit: 4
    t.datetime "last_force_destroyed"
  end

  add_index "agendas", ["event_id", "start_agenda_time"], name: "index_agendas_on_event_id_and_start_agenda_time", using: :btree
  add_index "agendas", ["event_id"], name: "index_agendas_on_event_id", using: :btree
  add_index "agendas", ["event_id"], name: "index_agendas_on_events_index", using: :btree
  add_index "agendas", ["parent_id"], name: "index_agendas_on_parent_id", using: :btree
  add_index "agendas", ["start_agenda_date"], name: "index_start_agenda_date_in agendas", using: :btree
  add_index "agendas", ["start_agenda_time"], name: "index_on_start_agenda_time_in_agendas", using: :btree
  add_index "agendas", ["updated_at", "event_id", "start_agenda_time"], name: "index_agendas_on_updated_at_and_event_id_and_start_agenda_time", using: :btree

  create_table "agendas_dayoptions", id: false, force: :cascade do |t|
    t.integer "dayoption_id", limit: 4, null: false
    t.integer "agenda_id",    limit: 4, null: false
  end

  add_index "agendas_dayoptions", ["agenda_id"], name: "index_agendas_dayoptions_on_agenda_id", using: :btree

  create_table "analytics", force: :cascade do |t|
    t.string   "viewable_type", limit: 255
    t.integer  "viewable_id",   limit: 4
    t.string   "action",        limit: 255
    t.integer  "invitee_id",    limit: 4
    t.integer  "event_id",      limit: 4
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "platform",      limit: 255
    t.integer  "points",        limit: 4
    t.string   "viewable_url",  limit: 255
    t.string   "status",        limit: 255, default: ""
  end

  add_index "analytics", ["action", "viewable_type", "invitee_id", "event_id"], name: "index_analytics_columns_in_analytics", length: {"action"=>191, "viewable_type"=>191, "invitee_id"=>nil, "event_id"=>nil}, using: :btree
  add_index "analytics", ["action"], name: "index_on_action_in_analytics", length: {"action"=>191}, using: :btree
  add_index "analytics", ["event_id", "action", "created_at"], name: "index_analytics_columns_in_analytic", length: {"event_id"=>nil, "action"=>191, "created_at"=>nil}, using: :btree
  add_index "analytics", ["event_id"], name: "index_on_event_id_in_analytics", using: :btree
  add_index "analytics", ["invitee_id"], name: "index_on_invitee_id_in_analytics", using: :btree
  add_index "analytics", ["platform"], name: "index_on_platform_in_analytics", length: {"platform"=>191}, using: :btree
  add_index "analytics", ["points"], name: "index_analytics_on_events_index", using: :btree
  add_index "analytics", ["viewable_id"], name: "index_on_viewable_id_in_analytics", using: :btree
  add_index "analytics", ["viewable_type"], name: "index_on_viewable_type_in_analytics", length: {"viewable_type"=>191}, using: :btree

  create_table "attendees", force: :cascade do |t|
    t.string   "attendee_name",           limit: 255
    t.string   "email_address",           limit: 255
    t.string   "company_name",            limit: 255
    t.string   "designation",             limit: 255
    t.string   "phone_number",            limit: 255
    t.string   "send_email",              limit: 255
    t.integer  "event_id",                limit: 4
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "event_timezone",          limit: 255
    t.integer  "parent_id",               limit: 4
    t.string   "event_timezone_offset",   limit: 255
    t.string   "event_display_time_zone", limit: 255
  end

  add_index "attendees", ["attendee_name"], name: "index_attendee_name_on_attendees", length: {"attendee_name"=>191}, using: :btree
  add_index "attendees", ["email_address"], name: "index_email_address_on_attendees", length: {"email_address"=>191}, using: :btree
  add_index "attendees", ["event_id"], name: "index_attendees_on_event_id", using: :btree
  add_index "attendees", ["parent_id"], name: "index_attendees_on_parent_id", using: :btree
  add_index "attendees", ["phone_number"], name: "index_phone_number_on_attendees", length: {"phone_number"=>191}, using: :btree

  create_table "auto_status_emails", force: :cascade do |t|
    t.integer  "event_id",            limit: 4
    t.text     "auto_approved_email", limit: 65535
    t.text     "auto_reject_email",   limit: 65535
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  create_table "awards", force: :cascade do |t|
    t.integer  "event_id",                limit: 4
    t.string   "title",                   limit: 255
    t.text     "description",             limit: 16777215
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.integer  "sequence",                limit: 4
    t.string   "event_timezone",          limit: 255
    t.integer  "parent_id",               limit: 4
    t.string   "event_timezone_offset",   limit: 255
    t.string   "event_display_time_zone", limit: 255
    t.datetime "last_force_destroyed"
  end

  add_index "awards", ["event_id", "sequence"], name: "index_awards_on_event_id_and_sequence", using: :btree
  add_index "awards", ["event_id"], name: "index_awards_on_event_id", using: :btree
  add_index "awards", ["parent_id"], name: "index_awards_on_parent_id", using: :btree
  add_index "awards", ["sequence"], name: "index_sequence_on_awards", using: :btree
  add_index "awards", ["title"], name: "index_title_on_awards", length: {"title"=>191}, using: :btree

  create_table "badge_pdfs", force: :cascade do |t|
    t.integer  "event_id",                 limit: 4
    t.string   "column1",                  limit: 255
    t.string   "column2",                  limit: 255
    t.string   "column3",                  limit: 255
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.string   "badge_image_file_name",    limit: 255
    t.string   "badge_image_content_type", limit: 255
    t.integer  "badge_image_file_size",    limit: 4
    t.datetime "badge_image_updated_at"
  end

  create_table "campaigns", force: :cascade do |t|
    t.integer  "event_id",         limit: 4
    t.string   "campaign_name",    limit: 255
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.datetime "start_date"
    t.datetime "end_date"
    t.string   "event_timezone",   limit: 255
    t.integer  "parent_id",        limit: 4
    t.string   "invitee_campaign", limit: 255
    t.string   "total_mails_sent", limit: 255
  end

  create_table "campaigns_events", id: false, force: :cascade do |t|
    t.integer "event_id",    limit: 4, null: false
    t.integer "campaign_id", limit: 4, null: false
  end

  add_index "campaigns_events", ["campaign_id", "event_id"], name: "index_campaigns_events_on_campaign_id_and_event_id", using: :btree
  add_index "campaigns_events", ["event_id", "campaign_id"], name: "index_campaigns_events_on_event_id_and_campaign_id", using: :btree

  create_table "chats", force: :cascade do |t|
    t.string   "chat_type",               limit: 255
    t.integer  "sender_id",               limit: 4
    t.string   "member_ids",              limit: 255
    t.datetime "date_time"
    t.integer  "event_id",                limit: 4
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.string   "message",                 limit: 255
    t.string   "event_timezone",          limit: 255
    t.string   "event_timezone_offset",   limit: 255
    t.string   "event_display_time_zone", limit: 255
    t.boolean  "unread",                  limit: 1,   default: true
  end

  create_table "cities", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "event_id",   limit: 4
  end

  add_index "cities", ["event_id"], name: "index_cities_on_event_id", using: :btree

  create_table "ckeditor_assets", force: :cascade do |t|
    t.string   "data_file_name",    limit: 255, null: false
    t.string   "data_content_type", limit: 255
    t.integer  "data_file_size",    limit: 4
    t.string   "data_fingerprint",  limit: 255
    t.integer  "assetable_id",      limit: 4
    t.string   "assetable_type",    limit: 30
    t.string   "type",              limit: 30
    t.integer  "width",             limit: 4
    t.integer  "height",            limit: 4
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "ckeditor_assets", ["assetable_type", "assetable_id"], name: "idx_ckeditor_assetable", using: :btree
  add_index "ckeditor_assets", ["assetable_type", "type", "assetable_id"], name: "idx_ckeditor_assetable_type", using: :btree

  create_table "clients", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "licensee_id", limit: 4
    t.string   "status",      limit: 255
    t.string   "client_code", limit: 255
    t.text     "remarks",     limit: 16777215
  end

  add_index "clients", ["licensee_id"], name: "index_clients_on_licensee_id", using: :btree
  add_index "clients", ["name"], name: "index_name_on_clients", length: {"name"=>191}, using: :btree
  add_index "clients", ["status"], name: "index_status_on_clients", length: {"status"=>191}, using: :btree

  create_table "clients_users", id: false, force: :cascade do |t|
    t.integer "client_id", limit: 4, null: false
    t.integer "user_id",   limit: 4, null: false
  end

  add_index "clients_users", ["client_id"], name: "index_clients_users_on_client_id", using: :btree
  add_index "clients_users", ["user_id"], name: "index_clients_users_on_user_id", using: :btree

  create_table "comments", force: :cascade do |t|
    t.integer  "commentable_id",   limit: 4
    t.string   "commentable_type", limit: 255
    t.integer  "user_id",          limit: 4
    t.text     "description",      limit: 65535
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.integer  "analytic_id",      limit: 4
  end

  add_index "comments", ["commentable_id", "commentable_type", "updated_at"], name: "index_comments_columns", length: {"commentable_id"=>nil, "commentable_type"=>100, "updated_at"=>nil}, using: :btree
  add_index "comments", ["commentable_id"], name: "index_commentable_id_comments", using: :btree
  add_index "comments", ["commentable_type"], name: "index_on_commentable_type_in_comments", length: {"commentable_type"=>191}, using: :btree
  add_index "comments", ["updated_at"], name: "index_updated_at_comments", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "contacts", force: :cascade do |t|
    t.integer  "event_id",     limit: 4
    t.string   "email",        limit: 255
    t.string   "name",         limit: 255
    t.string   "mobile",       limit: 255
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.text     "introduction", limit: 16777215
    t.integer  "parent_id",    limit: 4
  end

  add_index "contacts", ["event_id"], name: "index_contacts_on_event_id", using: :btree
  add_index "contacts", ["parent_id"], name: "index_contacts_on_parent_id", using: :btree

  create_table "conversation_walls", force: :cascade do |t|
    t.string   "background_color",              limit: 255
    t.string   "box_color",                     limit: 255
    t.string   "font_color",                    limit: 255
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.string   "logo_file_name",                limit: 255
    t.string   "logo_content_type",             limit: 255
    t.integer  "logo_file_size",                limit: 4
    t.datetime "logo_updated_at"
    t.integer  "event_id",                      limit: 4
    t.string   "background_image_file_name",    limit: 255
    t.string   "background_image_content_type", limit: 255
    t.integer  "background_image_file_size",    limit: 4
    t.datetime "background_image_updated_at"
    t.string   "sub_text_color",                limit: 255
  end

  create_table "conversations", force: :cascade do |t|
    t.text     "description",                     limit: 16777215
    t.integer  "event_id",                        limit: 4
    t.integer  "user_id",                         limit: 4
    t.string   "image_file_name",                 limit: 255
    t.string   "image_content_type",              limit: 255
    t.string   "image_file_size",                 limit: 255
    t.datetime "image_updated_at"
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.string   "status",                          limit: 255
    t.string   "on_wall",                         limit: 255
    t.string   "event_timezone",                  limit: 255
    t.integer  "event_timezone_offset",           limit: 4
    t.string   "event_display_time_zone",         limit: 255
    t.string   "action",                          limit: 255
    t.text     "last_update_comment_description", limit: 65535
    t.integer  "actioner_id",                     limit: 4
    t.string   "first_name_user",                 limit: 255
    t.string   "last_name_user",                  limit: 255
    t.string   "profile_pic_url_user",            limit: 255
    t.datetime "last_interaction_at"
    t.integer  "comments_count_cache",            limit: 4
    t.integer  "likes_count_cache",               limit: 4
    t.text     "json_data",                       limit: 65535
  end

  add_index "conversations", ["description"], name: "index_on_description_in_conversations", length: {"description"=>191}, using: :btree
  add_index "conversations", ["event_id"], name: "index_conversations_on_event_id", using: :btree
  add_index "conversations", ["updated_at", "event_id"], name: "index_conversations_on_updated_at_and_event_id", using: :btree
  add_index "conversations", ["updated_at"], name: "index_on_updated_at_in_conversations", using: :btree
  add_index "conversations", ["user_id"], name: "index_on_user_id_in_conversations", using: :btree

  create_table "course_providers", force: :cascade do |t|
    t.string   "provider_name",     limit: 255
    t.integer  "event_id",          limit: 4
    t.string   "logo_file_name",    limit: 255
    t.string   "logo_content_type", limit: 255
    t.integer  "logo_file_size",    limit: 4
    t.datetime "logo_updated_at"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  create_table "course_tags", force: :cascade do |t|
    t.integer  "course_id",  limit: 4
    t.string   "tag_name",   limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "courses", force: :cascade do |t|
    t.string   "title",              limit: 255
    t.string   "course_type",        limit: 255
    t.string   "code",               limit: 255
    t.string   "venue",              limit: 255
    t.string   "duration",           limit: 255
    t.datetime "start_time"
    t.datetime "end_time"
    t.float    "price",              limit: 24
    t.string   "offers",             limit: 255
    t.string   "hours_per_day",      limit: 255
    t.integer  "event_id",           limit: 4
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "course_provider_id", limit: 4
    t.integer  "sequence",           limit: 4
    t.string   "speaker_ids",        limit: 255
    t.string   "speaker_names",      limit: 255
    t.text     "all_speaker_names",  limit: 65535
  end

  create_table "custom_page1s", force: :cascade do |t|
    t.integer  "event_id",    limit: 4
    t.string   "page_type",   limit: 255
    t.string   "site_url",    limit: 255
    t.text     "description", limit: 4294967295
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "open_with",   limit: 255
    t.integer  "parent_id",   limit: 4
  end

  add_index "custom_page1s", ["parent_id"], name: "index_custom_page1s_on_parent_id", using: :btree

  create_table "custom_page2s", force: :cascade do |t|
    t.integer  "event_id",    limit: 4
    t.string   "page_type",   limit: 255
    t.string   "site_url",    limit: 255
    t.text     "description", limit: 4294967295
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "open_with",   limit: 255
    t.integer  "parent_id",   limit: 4
  end

  add_index "custom_page2s", ["parent_id"], name: "index_custom_page2s_on_parent_id", using: :btree

  create_table "custom_page3s", force: :cascade do |t|
    t.integer  "event_id",    limit: 4
    t.string   "page_type",   limit: 255
    t.string   "site_url",    limit: 255
    t.text     "description", limit: 4294967295
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "open_with",   limit: 255
    t.integer  "parent_id",   limit: 4
  end

  add_index "custom_page3s", ["parent_id"], name: "index_custom_page3s_on_parent_id", using: :btree

  create_table "custom_page4s", force: :cascade do |t|
    t.integer  "event_id",    limit: 4
    t.string   "page_type",   limit: 255
    t.string   "site_url",    limit: 255
    t.text     "description", limit: 4294967295
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "open_with",   limit: 255
    t.integer  "parent_id",   limit: 4
  end

  add_index "custom_page4s", ["parent_id"], name: "index_custom_page4s_on_parent_id", using: :btree

  create_table "custom_page5s", force: :cascade do |t|
    t.integer  "event_id",    limit: 4
    t.string   "page_type",   limit: 255
    t.string   "site_url",    limit: 255
    t.text     "description", limit: 4294967295
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "open_with",   limit: 255
    t.integer  "parent_id",   limit: 4
  end

  add_index "custom_page5s", ["parent_id"], name: "index_custom_page5s_on_parent_id", using: :btree

  create_table "dayoptions", force: :cascade do |t|
    t.string   "daytype",    limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "devices", force: :cascade do |t|
    t.integer  "user_id",               limit: 4
    t.string   "token",                 limit: 255
    t.string   "platform",              limit: 255
    t.string   "enabled",               limit: 255, default: "true"
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.integer  "invitee_id",            limit: 4
    t.string   "email",                 limit: 255
    t.integer  "client_id",             limit: 4
    t.integer  "mobile_application_id", limit: 4
  end

  add_index "devices", ["client_id"], name: "index_awards_on_client_id", using: :btree
  add_index "devices", ["invitee_id"], name: "index_devices_on_invitee_id", using: :btree
  add_index "devices", ["platform", "mobile_application_id", "invitee_id"], name: "index_devices_on_platform_and_id", length: {"platform"=>191, "mobile_application_id"=>nil, "invitee_id"=>nil}, using: :btree
  add_index "devices", ["user_id"], name: "index_devices_on_user_id", using: :btree

  create_table "e_kits", force: :cascade do |t|
    t.integer  "event_id",                limit: 4
    t.string   "name",                    limit: 255
    t.string   "tag_name",                limit: 255
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "attachment_file_name",    limit: 255
    t.string   "attachment_content_type", limit: 255
    t.integer  "attachment_file_size",    limit: 4
    t.datetime "attachment_updated_at"
  end

  add_index "e_kits", ["event_id", "updated_at"], name: "index_e_kits_on_event_id_and_updated_at", using: :btree
  add_index "e_kits", ["event_id", "updated_at"], name: "index_e_kits_on_events_id", using: :btree
  add_index "e_kits", ["event_id"], name: "index_e_kits_on_event_id", using: :btree
  add_index "e_kits", ["updated_at"], name: "index_e_kits_on_events_index", using: :btree

  create_table "edm_mail_sents", force: :cascade do |t|
    t.integer  "event_id",         limit: 4
    t.integer  "edm_id",           limit: 4
    t.string   "email",            limit: 255
    t.string   "open",             limit: 255, default: "no"
    t.string   "status",           limit: 255, default: "sent"
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.boolean  "invitee_campaign", limit: 1,   default: false
  end

  create_table "edms", force: :cascade do |t|
    t.integer  "campaign_id",               limit: 4
    t.string   "subject_line",              limit: 255
    t.datetime "edm_broadcast_time"
    t.string   "template_type",             limit: 255
    t.text     "custom_code",               limit: 16777215
    t.string   "default_template",          limit: 255
    t.string   "edm_broadcast_value",       limit: 255
    t.string   "header_image_file_name",    limit: 255
    t.string   "header_image_content_type", limit: 255
    t.integer  "header_image_file_size",    limit: 4
    t.datetime "header_image_updated_at"
    t.string   "footer_image_file_name",    limit: 255
    t.string   "footer_image_content_type", limit: 255
    t.integer  "footer_image_file_size",    limit: 4
    t.datetime "footer_image_updated_at"
    t.text     "body",                      limit: 16777215
    t.string   "flag",                      limit: 255,      default: "0"
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
    t.string   "group_type",                limit: 255
    t.string   "group_id",                  limit: 255
    t.string   "database_email_field",      limit: 255
    t.string   "need_social_icon",          limit: 255
    t.string   "social_icons",              limit: 255
    t.string   "email_sent",                limit: 255
    t.string   "registered",                limit: 255
    t.string   "registration_approved",     limit: 255
    t.string   "confirmed",                 limit: 255
    t.string   "attended",                  limit: 255
    t.string   "email_opened",              limit: 255
    t.string   "sent",                      limit: 255
    t.string   "facebook_link",             limit: 255
    t.string   "google_plus_link",          limit: 255
    t.string   "linkedin_link",             limit: 255
    t.string   "twitter_link",              limit: 255
    t.string   "header_color",              limit: 255
    t.string   "footer_color",              limit: 255
    t.string   "sender_email",              limit: 255
    t.string   "event_timezone",            limit: 255
    t.string   "mail_to",                   limit: 255
    t.integer  "event_id",                  limit: 4
    t.string   "reply_to_email",            limit: 255
    t.string   "sender_name",               limit: 255
    t.string   "track_link_1_id",           limit: 255
    t.string   "track_link_2_id",           limit: 255
    t.string   "track_link_3_id",           limit: 255
    t.string   "event_timezone_offset",     limit: 255
    t.string   "event_display_time_zone",   limit: 255
  end

  create_table "emergency_exits", force: :cascade do |t|
    t.string   "event_name",                  limit: 255
    t.integer  "event_id",                    limit: 4
    t.string   "title",                       limit: 255
    t.string   "emergency_exit_file_name",    limit: 255
    t.string   "emergency_exit_content_type", limit: 255
    t.integer  "emergency_exit_file_size",    limit: 4
    t.datetime "emergency_exit_updated_at"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.string   "uber_link",                   limit: 255
    t.string   "icon_file_name",              limit: 255
    t.string   "icon_content_type",           limit: 255
    t.integer  "icon_file_size",              limit: 4
    t.datetime "icon_updated_at"
    t.integer  "parent_id",                   limit: 4
  end

  add_index "emergency_exits", ["event_id"], name: "index_emergency_exits_on_event_id", using: :btree
  add_index "emergency_exits", ["parent_id"], name: "index_emergency_exits_on_parent_id", using: :btree

  create_table "event_features", force: :cascade do |t|
    t.string   "name",                             limit: 255
    t.integer  "event_id",                         limit: 4
    t.string   "menu_icon_file_name",              limit: 255
    t.string   "menu_icon_content_type",           limit: 255
    t.integer  "menu_icon_file_size",              limit: 4
    t.datetime "menu_icon_updated_at"
    t.string   "main_icon_file_name",              limit: 255
    t.string   "main_icon_content_type",           limit: 255
    t.integer  "main_icon_file_size",              limit: 4
    t.datetime "main_icon_updated_at"
    t.datetime "created_at",                                                           null: false
    t.datetime "updated_at",                                                           null: false
    t.string   "page_title",                       limit: 255
    t.string   "status",                           limit: 255,      default: "active"
    t.integer  "sequence",                         limit: 4
    t.text     "description",                      limit: 16777215
    t.string   "menu_visibilty",                   limit: 255
    t.string   "menu_icon_visibility",             limit: 255,      default: "yes"
    t.string   "interpolate_time_stamp",           limit: 255
    t.string   "main_icon_interpolate_time_stamp", limit: 255
    t.string   "event_timezone",                   limit: 255
    t.integer  "parent_id",                        limit: 4
    t.string   "event_timezone_offset",            limit: 255
    t.string   "event_display_time_zone",          limit: 255
    t.datetime "last_force_destroyed"
  end

  add_index "event_features", ["event_id"], name: "index_event_features_on_event_id", using: :btree
  add_index "event_features", ["name"], name: "index_on_name_in_event_features", length: {"name"=>191}, using: :btree
  add_index "event_features", ["sequence"], name: "index_on_sequence_in_event_features", using: :btree
  add_index "event_features", ["updated_at", "event_id", "sequence"], name: "index_event_features_on_updated_at_and_event_id_and_sequence", using: :btree

  create_table "event_groups", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.text     "remarks",    limit: 16777215
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "client_id",  limit: 4
  end

  add_index "event_groups", ["client_id"], name: "index_event_groups_on_client_id", using: :btree
  add_index "event_groups", ["name"], name: "index_name_on_event_groups", length: {"name"=>191}, using: :btree

  create_table "event_venues", force: :cascade do |t|
    t.integer  "event_id",   limit: 4
    t.string   "venue",      limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "events", force: :cascade do |t|
    t.string   "client_name",                   limit: 255
    t.string   "business_unit",                 limit: 255
    t.string   "event_code",                    limit: 255
    t.string   "event_name",                    limit: 255
    t.string   "event_type",                    limit: 255
    t.boolean  "multi_city",                    limit: 1
    t.string   "cities",                        limit: 255
    t.datetime "start_event_date"
    t.datetime "end_event_date"
    t.datetime "start_event_time"
    t.datetime "end_event_time"
    t.string   "venues",                        limit: 255
    t.string   "pax",                           limit: 255
    t.string   "event_admin_field",             limit: 255
    t.string   "event_manager_field",           limit: 255
    t.string   "event_executive_field",         limit: 255
    t.integer  "client_id",                     limit: 4
    t.datetime "created_at",                                                          null: false
    t.datetime "updated_at",                                                          null: false
    t.integer  "city_id",                       limit: 4
    t.string   "logo_file_name",                limit: 255
    t.string   "logo_content_type",             limit: 255
    t.integer  "logo_file_size",                limit: 4
    t.datetime "logo_updated_at"
    t.text     "description",                   limit: 16777215
    t.string   "status",                        limit: 255
    t.string   "display_type",                  limit: 255
    t.string   "inside_logo_file_name",         limit: 255
    t.string   "inside_logo_content_type",      limit: 255
    t.integer  "inside_logo_file_size",         limit: 4
    t.datetime "inside_logo_updated_at"
    t.integer  "theme_id",                      limit: 4
    t.text     "summary",                       limit: 16777215
    t.text     "about",                         limit: 16777215
    t.integer  "mobile_application_id",         limit: 4
    t.string   "schedule_type",                 limit: 255
    t.string   "google_map_link",               limit: 255
    t.text     "remarks",                       limit: 16777215
    t.string   "login_at",                      limit: 255
    t.string   "menu_saved",                    limit: 255
    t.string   "rsvp",                          limit: 255,      default: "No"
    t.text     "rsvp_message",                  limit: 16777215
    t.string   "countdown_ticker",              limit: 255,      default: "No"
    t.string   "default_feature_icon",          limit: 255,      default: "new_menu"
    t.string   "conversation_auto_approve",     limit: 255,      default: "false"
    t.string   "qna_auto_approve",              limit: 255,      default: "false"
    t.string   "poll_auto_approve",             limit: 255,      default: "true"
    t.string   "highlight_saved",               limit: 255
    t.text     "token",                         limit: 16777215
    t.string   "timezone",                      limit: 255
    t.string   "event_category",                limit: 255
    t.datetime "old_start_event_date"
    t.datetime "old_end_event_date"
    t.datetime "old_start_event_time"
    t.datetime "old_end_event_time"
    t.integer  "parent_id",                     limit: 4
    t.string   "country_name",                  limit: 255
    t.integer  "timezone_offset",               limit: 4
    t.string   "custom_content",                limit: 255
    t.string   "copy_content",                  limit: 255
    t.string   "copy_event",                    limit: 255
    t.boolean  "show_social_feed",              limit: 1
    t.boolean  "set_activity_feed_as_homepage", limit: 1
    t.string   "event_type_for_registration",   limit: 255
    t.string   "twitter_social_tags",           limit: 255
    t.string   "facebook_social_tags",          limit: 255
    t.string   "twitter_handle",                limit: 255
    t.boolean  "show_social_feeds",             limit: 1
    t.datetime "last_tweet_date"
    t.string   "instagram_access_token",        limit: 255
    t.string   "instagram_code",                limit: 255
    t.string   "instagram_secret_token",        limit: 255
    t.string   "instagram_social_tags",         limit: 255
    t.string   "instagram_client_id",           limit: 255
    t.boolean  "marketing_app",                 limit: 1
    t.datetime "published_at"
    t.string   "copy_content_button",           limit: 255
    t.string   "homepage_feature_name",         limit: 255
    t.integer  "homepage_feature_id",           limit: 4
    t.string   "footer_image_file_name",        limit: 255
    t.string   "footer_image_content_type",     limit: 255
    t.integer  "footer_image_file_size",        limit: 4
    t.datetime "footer_image_updated_at"
  end

  add_index "events", ["city_id"], name: "index_events_on_city_id", using: :btree
  add_index "events", ["client_id"], name: "index_events_on_client_id", using: :btree
  add_index "events", ["end_event_date"], name: "index_end_event_date_on_events", using: :btree
  add_index "events", ["end_event_time"], name: "index_end_event_time_on_events", using: :btree
  add_index "events", ["event_code"], name: "index_event_code_on_events", length: {"event_code"=>191}, using: :btree
  add_index "events", ["event_name"], name: "index_event_name_on_events", length: {"event_name"=>191}, using: :btree
  add_index "events", ["id", "created_at"], name: "index_events_on_id_and_created_at", using: :btree
  add_index "events", ["mobile_application_id"], name: "index_events_on_mobile_application_id", using: :btree
  add_index "events", ["parent_id"], name: "index_events_on_parent_id", using: :btree
  add_index "events", ["start_event_date", "end_event_date"], name: "index_dates_on_events", using: :btree
  add_index "events", ["start_event_date"], name: "index_start_event_date_on_events", using: :btree
  add_index "events", ["start_event_time"], name: "index_start_event_time_on_events", using: :btree
  add_index "events", ["status"], name: "index_status_on_events", length: {"status"=>191}, using: :btree
  add_index "events", ["theme_id"], name: "index_events_on_theme_id", using: :btree
  add_index "events", ["updated_at"], name: "index_events_on_updated_at", using: :btree

  create_table "events_mobile_applications", force: :cascade do |t|
    t.integer  "event_id",              limit: 4
    t.integer  "mobile_application_id", limit: 4
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  add_index "events_mobile_applications", ["event_id"], name: "index_events_mobile_applications_on_event_id", using: :btree

  create_table "events_users", id: false, force: :cascade do |t|
    t.integer "user_id",  limit: 4, null: false
    t.integer "event_id", limit: 4, null: false
  end

  add_index "events_users", ["event_id", "user_id"], name: "index_events_users_on_event_id_and_user_id", using: :btree
  add_index "events_users", ["user_id", "event_id"], name: "index_events_users_on_user_id_and_event_id", using: :btree

  create_table "exhibitors", force: :cascade do |t|
    t.integer  "event_id",             limit: 4
    t.string   "exhibitor_type",       limit: 255
    t.string   "name",                 limit: 255
    t.string   "email",                limit: 255
    t.text     "description",          limit: 16777215
    t.text     "website_url",          limit: 16777215
    t.string   "image_file_name",      limit: 255
    t.string   "image_content_type",   limit: 255
    t.integer  "image_file_size",      limit: 4
    t.datetime "image_updated_at"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.text     "url",                  limit: 16777215
    t.integer  "sequence",             limit: 4
    t.integer  "parent_id",            limit: 4
    t.string   "contact_person_name",  limit: 255
    t.string   "mobile",               limit: 255
    t.datetime "last_force_destroyed"
  end

  add_index "exhibitors", ["parent_id"], name: "index_exhibitors_on_parent_id", using: :btree

  create_table "faqs", force: :cascade do |t|
    t.text     "question",                limit: 16777215
    t.text     "answer",                  limit: 16777215
    t.integer  "event_id",                limit: 4
    t.integer  "user_id",                 limit: 4
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.float    "sequence",                limit: 24
    t.string   "event_timezone",          limit: 255
    t.integer  "parent_id",               limit: 4
    t.string   "event_timezone_offset",   limit: 255
    t.string   "event_display_time_zone", limit: 255
    t.datetime "last_force_destroyed"
  end

  add_index "faqs", ["answer"], name: "index_on_answer_in_faqs", length: {"answer"=>191}, using: :btree
  add_index "faqs", ["event_id"], name: "index_faqs_on_event_id", using: :btree
  add_index "faqs", ["parent_id"], name: "index_faqs_on_parent_id", using: :btree
  add_index "faqs", ["question"], name: "index_on_question_in_faqs", length: {"question"=>191}, using: :btree
  add_index "faqs", ["sequence"], name: "index_on_sequence_in_faqs", using: :btree
  add_index "faqs", ["updated_at", "event_id", "sequence"], name: "index_faqs_on_updated_at_and_event_id_and_sequence", using: :btree
  add_index "faqs", ["user_id"], name: "index_faqs_on_user_id", using: :btree

  create_table "favorites", force: :cascade do |t|
    t.integer  "invitee_id",       limit: 4
    t.string   "favoritable_type", limit: 255
    t.integer  "favoritable_id",   limit: 4
    t.string   "status",           limit: 255, default: "active"
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.integer  "event_id",         limit: 4
  end

  add_index "favorites", ["created_at"], name: "index_favorites_on_created_at", using: :btree
  add_index "favorites", ["event_id"], name: "index_favorites_on_event_id", using: :btree
  add_index "favorites", ["favoritable_id", "favoritable_type"], name: "index_favorites_on_favoritable_id_and_favoritable_type", length: {"favoritable_id"=>nil, "favoritable_type"=>191}, using: :btree
  add_index "favorites", ["favoritable_type"], name: "index_favorites_on_favoritable_type", length: {"favoritable_type"=>191}, using: :btree
  add_index "favorites", ["id"], name: "index_favorites_on_id", using: :btree
  add_index "favorites", ["invitee_id", "updated_at"], name: "index_favorites_on_events_index", using: :btree
  add_index "favorites", ["invitee_id"], name: "index_favorites_on_invitee_id", using: :btree

  create_table "feedback_forms", force: :cascade do |t|
    t.integer  "sequence",             limit: 4
    t.text     "title",                limit: 65535
    t.integer  "event_id",             limit: 4
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.string   "status",               limit: 255,   default: "active"
    t.datetime "last_force_destroyed"
  end

  add_index "feedback_forms", ["sequence"], name: "index_feedback_forms_on_sequence", using: :btree

  create_table "feedbacks", force: :cascade do |t|
    t.integer  "event_id",                limit: 4
    t.string   "question",                limit: 255
    t.string   "option1",                 limit: 255
    t.string   "option2",                 limit: 255
    t.string   "option3",                 limit: 255
    t.string   "option4",                 limit: 255
    t.string   "option5",                 limit: 255
    t.string   "option_type",             limit: 255
    t.boolean  "description",             limit: 1
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "sequence",                limit: 4
    t.string   "option6",                 limit: 255
    t.string   "option7",                 limit: 255
    t.string   "option8",                 limit: 255
    t.string   "option9",                 limit: 255
    t.string   "option10",                limit: 255
    t.string   "event_timezone",          limit: 255
    t.integer  "parent_id",               limit: 4
    t.string   "event_timezone_offset",   limit: 255
    t.string   "event_display_time_zone", limit: 255
    t.integer  "feedback_form_id",        limit: 4
    t.datetime "last_force_destroyed"
  end

  add_index "feedbacks", ["event_id"], name: "index_feedbacks_on_event_id", using: :btree
  add_index "feedbacks", ["parent_id"], name: "index_feedbacks_on_parent_id", using: :btree
  add_index "feedbacks", ["question"], name: "index_question_on_feedbacks", length: {"question"=>191}, using: :btree
  add_index "feedbacks", ["updated_at", "event_id", "sequence"], name: "index_feedbacks_on_updated_at_and_event_id_and_sequence", using: :btree

  create_table "groupings", force: :cascade do |t|
    t.integer  "event_id",                limit: 4
    t.string   "name",                    limit: 255
    t.text     "condition",               limit: 16777215
    t.datetime "created_at",                                                 null: false
    t.datetime "updated_at",                                                 null: false
    t.string   "default_group",           limit: 255,      default: "false"
    t.string   "event_timezone",          limit: 255
    t.integer  "parent_id",               limit: 4
    t.string   "event_timezone_offset",   limit: 255
    t.string   "event_display_time_zone", limit: 255
  end

  add_index "groupings", ["parent_id"], name: "index_groupings_on_parent_id", using: :btree

  create_table "highlight_images", force: :cascade do |t|
    t.string   "name",                         limit: 255
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.string   "highlight_image_file_name",    limit: 255
    t.string   "highlight_image_content_type", limit: 255
    t.integer  "highlight_image_file_size",    limit: 4
    t.datetime "highlight_image_updated_at"
    t.integer  "event_id",                     limit: 4
    t.integer  "parent_id",                    limit: 4
  end

  add_index "highlight_images", ["event_id"], name: "index_highlight_images_on_event_id", using: :btree
  add_index "highlight_images", ["parent_id"], name: "index_highlight_images_on_parent_id", using: :btree

  create_table "icon_libraries", force: :cascade do |t|
    t.integer  "licensee_id",       limit: 4
    t.string   "icon_library_name", limit: 255
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  create_table "icons", force: :cascade do |t|
    t.integer  "icon_library_id",        limit: 4
    t.string   "icon_name",              limit: 255
    t.string   "menu_icon_file_name",    limit: 255
    t.string   "menu_icon_content_type", limit: 255
    t.integer  "menu_icon_file_size",    limit: 4
    t.datetime "menu_icon_updated_at"
    t.string   "main_icon_file_name",    limit: 255
    t.string   "main_icon_content_type", limit: 255
    t.integer  "main_icon_file_size",    limit: 4
    t.datetime "main_icon_updated_at"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  create_table "images", force: :cascade do |t|
    t.string   "name",               limit: 255
    t.integer  "imageable_id",       limit: 4
    t.string   "imageable_type",     limit: 255
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "image_file_name",    limit: 255
    t.string   "image_content_type", limit: 255
    t.integer  "image_file_size",    limit: 4
    t.datetime "image_updated_at"
    t.integer  "sequence",           limit: 4
    t.integer  "parent_id",          limit: 4
  end

  add_index "images", ["imageable_id"], name: "index_images_on_imageable_id", using: :btree
  add_index "images", ["imageable_type"], name: "index_on_imageable_type_in_images", length: {"imageable_type"=>191}, using: :btree
  add_index "images", ["parent_id"], name: "index_images_on_parent_id", using: :btree
  add_index "images", ["updated_at"], name: "index_images_on_events_index", using: :btree

  create_table "imports", force: :cascade do |t|
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.string   "import_file_file_name",    limit: 255
    t.string   "import_file_content_type", limit: 255
    t.integer  "import_file_file_size",    limit: 4
    t.datetime "import_file_updated_at"
    t.string   "importable_type",          limit: 255
    t.integer  "importable_id",            limit: 4
  end

  add_index "imports", ["importable_id"], name: "index_imports_on_importable_id", using: :btree

  create_table "invitee_accesses", force: :cascade do |t|
    t.integer  "event_id",         limit: 4
    t.integer  "invitee_id",       limit: 4
    t.integer  "venue_section_id", limit: 4
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "invitee_data", force: :cascade do |t|
    t.integer  "invitee_structure_id",      limit: 4
    t.string   "attr1",                     limit: 255
    t.string   "attr2",                     limit: 255
    t.string   "attr3",                     limit: 255
    t.string   "attr4",                     limit: 255
    t.string   "attr5",                     limit: 255
    t.string   "attr6",                     limit: 255
    t.string   "attr7",                     limit: 255
    t.string   "attr8",                     limit: 255
    t.string   "attr9",                     limit: 255
    t.string   "attr10",                    limit: 255
    t.string   "attr11",                    limit: 255
    t.string   "attr12",                    limit: 255
    t.string   "attr13",                    limit: 255
    t.string   "attr14",                    limit: 255
    t.string   "attr15",                    limit: 255
    t.string   "attr16",                    limit: 255
    t.string   "attr17",                    limit: 255
    t.string   "attr18",                    limit: 255
    t.string   "status",                    limit: 255
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.string   "remark",                    limit: 255
    t.string   "attr19",                    limit: 255
    t.string   "attr20",                    limit: 255
    t.datetime "callback_datetime"
    t.integer  "telecaller_id",             limit: 4
    t.string   "reported_status",           limit: 255
    t.datetime "invitee_data_updated"
    t.integer  "call_attempt",              limit: 4,   default: 1
    t.string   "telecaller_update_count",   limit: 255
    t.string   "registration_update_count", limit: 255
  end

  create_table "invitee_groups", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.integer  "event_id",    limit: 4
    t.integer  "group_id",    limit: 4
    t.text     "invitee_ids", limit: 16777215
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "parent_id",   limit: 4
  end

  add_index "invitee_groups", ["event_id", "name"], name: "index_columns_on_invitee_groups", length: {"event_id"=>nil, "name"=>191}, using: :btree
  add_index "invitee_groups", ["event_id"], name: "index_event_id_on_invitee_groups", using: :btree
  add_index "invitee_groups", ["name"], name: "index_name_on_invitee_groups", length: {"name"=>191}, using: :btree
  add_index "invitee_groups", ["parent_id"], name: "index_invitee_groups_on_parent_id", using: :btree

  create_table "invitee_notifications", force: :cascade do |t|
    t.integer  "event_id",        limit: 4
    t.integer  "invitee_id",      limit: 4
    t.integer  "notification_id", limit: 4
    t.string   "open",            limit: 255, default: "false"
    t.string   "unread",          limit: 255, default: "true"
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.string   "event_timezone",  limit: 255
  end

  add_index "invitee_notifications", ["event_id", "invitee_id"], name: "index_invitee_notifications_on_event_id_and_invitee_id", using: :btree
  add_index "invitee_notifications", ["notification_id", "invitee_id"], name: "index_invitee_notifications_on_api", using: :btree
  add_index "invitee_notifications", ["notification_id", "invitee_id"], name: "index_invitee_notifications_on_notification_id_and_invitee_id", using: :btree
  add_index "invitee_notifications", ["notification_id"], name: "index_invitee_notifications_on_notification_id", using: :btree
  add_index "invitee_notifications", ["notification_id"], name: "index_notification_id_on_invitee_notifications", using: :btree
  add_index "invitee_notifications", ["updated_at", "event_id", "invitee_id"], name: "index_invitee_noti_updated_at_event_id_invitee_id", using: :btree

  create_table "invitee_structures", force: :cascade do |t|
    t.integer  "event_id",        limit: 4
    t.string   "attr1",           limit: 255
    t.string   "attr2",           limit: 255
    t.string   "attr3",           limit: 255
    t.string   "attr4",           limit: 255
    t.string   "attr5",           limit: 255
    t.string   "attr6",           limit: 255
    t.string   "attr7",           limit: 255
    t.string   "attr8",           limit: 255
    t.string   "attr9",           limit: 255
    t.string   "attr10",          limit: 255
    t.string   "attr11",          limit: 255
    t.string   "attr12",          limit: 255
    t.string   "attr13",          limit: 255
    t.string   "attr14",          limit: 255
    t.string   "attr15",          limit: 255
    t.string   "attr16",          limit: 255
    t.string   "attr17",          limit: 255
    t.string   "attr18",          limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "uniq_identifier", limit: 255
    t.string   "attr19",          limit: 255
    t.string   "attr20",          limit: 255
    t.string   "email_field",     limit: 255
    t.integer  "parent_id",       limit: 4
    t.string   "mandate_attr2",   limit: 255
    t.string   "mandate_attr3",   limit: 255
    t.string   "mandate_attr4",   limit: 255
    t.string   "mandate_attr5",   limit: 255
    t.string   "mandate_attr6",   limit: 255
    t.string   "mandate_attr7",   limit: 255
    t.string   "mandate_attr8",   limit: 255
    t.string   "mandate_attr9",   limit: 255
    t.string   "mandate_attr10",  limit: 255
    t.string   "mandate_attr11",  limit: 255
    t.string   "mandate_attr12",  limit: 255
    t.string   "mandate_attr13",  limit: 255
    t.string   "mandate_attr14",  limit: 255
    t.string   "mandate_attr15",  limit: 255
    t.string   "mandate_attr16",  limit: 255
    t.string   "mandate_attr17",  limit: 255
    t.string   "mandate_attr18",  limit: 255
    t.string   "mandate_attr19",  limit: 255
    t.string   "mandate_attr20",  limit: 255
  end

  add_index "invitee_structures", ["parent_id"], name: "index_invitee_structures_on_parent_id", using: :btree

  create_table "invitees", force: :cascade do |t|
    t.string   "event_name",                limit: 255
    t.string   "name_of_the_invitee",       limit: 255
    t.string   "email",                     limit: 255
    t.string   "company_name",              limit: 255
    t.string   "invitee_status",            limit: 255
    t.integer  "event_id",                  limit: 4
    t.datetime "created_at",                                                   null: false
    t.datetime "updated_at",                                                   null: false
    t.integer  "badge_count",               limit: 4
    t.string   "encrypted_password",        limit: 255,      default: "",      null: false
    t.string   "salt",                      limit: 255
    t.string   "key",                       limit: 255
    t.string   "secret_key",                limit: 255
    t.string   "authentication_token",      limit: 255
    t.string   "designation",               limit: 255
    t.string   "visible_status",            limit: 255
    t.string   "mobile_no",                 limit: 255
    t.string   "website",                   limit: 255
    t.string   "street",                    limit: 255
    t.string   "locality",                  limit: 255
    t.string   "location",                  limit: 255
    t.string   "country",                   limit: 255
    t.string   "qr_code_file_name",         limit: 255
    t.string   "qr_code_content_type",      limit: 255
    t.integer  "qr_code_file_size",         limit: 4
    t.datetime "qr_code_updated_at"
    t.string   "profile_pic_file_name",     limit: 255
    t.string   "profile_pic_content_type",  limit: 255
    t.integer  "profile_pic_file_size",     limit: 4
    t.datetime "profile_pic_updated_at"
    t.text     "about",                     limit: 16777215
    t.string   "interested_topics",         limit: 255
    t.text     "twitter_id",                limit: 65535
    t.text     "facebook_id",               limit: 65535
    t.datetime "last_interation"
    t.integer  "points",                    limit: 4,        default: 0
    t.string   "first_name",                limit: 255
    t.string   "last_name",                 limit: 255
    t.text     "google_id",                 limit: 16777215
    t.text     "linkedin_id",               limit: 16777215
    t.string   "provider",                  limit: 255
    t.string   "invitee_password",          limit: 255
    t.string   "email_send",                limit: 255,      default: "false"
    t.boolean  "previous_scan",             limit: 1,        default: false
    t.boolean  "successful_scan",           limit: 1,        default: false
    t.datetime "notification_viewed_at"
    t.text     "remark",                    limit: 65535
    t.boolean  "qr_code_registration",      limit: 1
    t.string   "event_timezone",            limit: 255
    t.boolean  "onsite_registration",       limit: 1
    t.text     "attr1",                     limit: 65535
    t.text     "attr2",                     limit: 65535
    t.text     "attr3",                     limit: 65535
    t.text     "attr4",                     limit: 65535
    t.text     "attr5",                     limit: 65535
    t.integer  "parent_id",                 limit: 4
    t.string   "event_timezone_offset",     limit: 255
    t.string   "event_display_time_zone",   limit: 255
    t.string   "instagram_id",              limit: 255
    t.datetime "qr_code_registration_time"
  end

  add_index "invitees", ["authentication_token"], name: "index_on_authentication_token_in_invitees", length: {"authentication_token"=>191}, using: :btree
  add_index "invitees", ["company_name"], name: "index_on_company_name_in_invitees", length: {"company_name"=>191}, using: :btree
  add_index "invitees", ["email"], name: "index_on_email_in_invitees", length: {"email"=>191}, using: :btree
  add_index "invitees", ["event_id", "email"], name: "index_event_and_email_on_invitees", length: {"event_id"=>nil, "email"=>100}, using: :btree
  add_index "invitees", ["event_id", "email"], name: "index_invitees_on_api", length: {"event_id"=>nil, "email"=>100}, using: :btree
  add_index "invitees", ["event_id", "visible_status"], name: "index_invitees_on_events_index", length: {"event_id"=>nil, "visible_status"=>100}, using: :btree
  add_index "invitees", ["event_id"], name: "index_invitees_on_event_id", using: :btree
  add_index "invitees", ["key"], name: "index_invitees_on_key", length: {"key"=>191}, using: :btree
  add_index "invitees", ["last_interation"], name: "index_last_interation_on_invitees", using: :btree
  add_index "invitees", ["name_of_the_invitee"], name: "index_name_of_the_invitee_on_invitees", length: {"name_of_the_invitee"=>191}, using: :btree
  add_index "invitees", ["parent_id"], name: "index_invitees_on_parent_id", using: :btree
  add_index "invitees", ["updated_at"], name: "index_inviteees_on_events_index", using: :btree
  add_index "invitees", ["visible_status"], name: "index_on_visible_status_in_invitees", length: {"visible_status"=>191}, using: :btree

  create_table "last_updated_models", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.datetime "last_updated"
  end

  add_index "last_updated_models", ["last_updated"], name: "index_last_updated_models_on_last_updated", using: :btree
  add_index "last_updated_models", ["last_updated"], name: "last_updated", using: :btree
  add_index "last_updated_models", ["name", "last_updated"], name: "index_last_updated_models_on_name_and_last_updated", length: {"name"=>191, "last_updated"=>nil}, using: :btree
  add_index "last_updated_models", ["name"], name: "index_last_updated_models_on_name", length: {"name"=>191}, using: :btree

  create_table "licensees", force: :cascade do |t|
    t.string   "name",               limit: 255
    t.string   "email",              limit: 255
    t.string   "company",            limit: 255
    t.string   "status",             limit: 255
    t.date     "licence_start_date"
    t.date     "licence_end_date"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  create_table "likes", force: :cascade do |t|
    t.integer  "likable_id",   limit: 4
    t.string   "likable_type", limit: 255
    t.integer  "user_id",      limit: 4
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "likes", ["likable_id", "likable_type", "updated_at"], name: "index_likes_on_events", length: {"likable_id"=>nil, "likable_type"=>191, "updated_at"=>nil}, using: :btree
  add_index "likes", ["likable_id"], name: "index_likes_on_likable_id", using: :btree
  add_index "likes", ["likable_type", "likable_id", "created_at"], name: "index_columns_on_likes", length: {"likable_type"=>191, "likable_id"=>nil, "created_at"=>nil}, using: :btree
  add_index "likes", ["likable_type", "likable_id", "updated_at"], name: "index_likes_on_likable_type_and_likable_id_and_updated_at", length: {"likable_type"=>191, "likable_id"=>nil, "updated_at"=>nil}, using: :btree
  add_index "likes", ["likable_type"], name: "index_on_likable_type_in_likes", length: {"likable_type"=>191}, using: :btree
  add_index "likes", ["user_id"], name: "index_likes_on_user_id", using: :btree

  create_table "log_changes", force: :cascade do |t|
    t.text     "changed_data",  limit: 16777215
    t.integer  "user_id",       limit: 4
    t.string   "resourse_type", limit: 255
    t.integer  "resourse_id",   limit: 4
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "action",        limit: 255
  end

  add_index "log_changes", ["action", "created_at", "updated_at"], name: "index_log_changes_on_action_and_created_at_and_updated_at", length: {"action"=>191, "created_at"=>nil, "updated_at"=>nil}, using: :btree
  add_index "log_changes", ["action"], name: "index_on_action_in_log_changes", length: {"action"=>191}, using: :btree
  add_index "log_changes", ["created_at", "action"], name: "index_log_changes_on_events_index", length: {"created_at"=>nil, "action"=>100}, using: :btree
  add_index "log_changes", ["created_at"], name: "index_on_created_at_in_log_changes", using: :btree
  add_index "log_changes", ["resourse_id"], name: "index_faqs_on_resourse_id", using: :btree
  add_index "log_changes", ["resourse_type", "resourse_id"], name: "index_resources_on_log_changes", length: {"resourse_type"=>100, "resourse_id"=>nil}, using: :btree
  add_index "log_changes", ["resourse_type"], name: "index_log_changes_on_resourse_type", length: {"resourse_type"=>191}, using: :btree
  add_index "log_changes", ["updated_at"], name: "index_on_updated_at_in_log_changes", using: :btree
  add_index "log_changes", ["user_id"], name: "index_log_changes_on_user_id", using: :btree

  create_table "manage_invitee_fields", force: :cascade do |t|
    t.integer  "event_id",     limit: 4
    t.string   "email",        limit: 255, default: "true"
    t.string   "company_name", limit: 255, default: "true"
    t.string   "designation",  limit: 255, default: "true"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.string   "first_name",   limit: 255, default: "true"
    t.string   "last_name",    limit: 255, default: "true"
  end

  create_table "microsites", force: :cascade do |t|
    t.string   "subject_line",              limit: 255
    t.string   "template_type",             limit: 255
    t.string   "default_template",          limit: 255
    t.string   "select_font",               limit: 255
    t.string   "header_image_file_name",    limit: 255
    t.string   "header_image_content_type", limit: 255
    t.string   "header_image_file_size",    limit: 255
    t.string   "header_image_updated_at",   limit: 255
    t.string   "banner_image_file_name",    limit: 255
    t.string   "banner_image_content_type", limit: 255
    t.string   "banner_image_file_size",    limit: 255
    t.string   "banner_image_updated_at",   limit: 255
    t.string   "logo_image_file_name",      limit: 255
    t.string   "logo_image_content_type",   limit: 255
    t.string   "logo_image_file_size",      limit: 255
    t.string   "logo_image_updated_at",     limit: 255
    t.string   "need_social_icon",          limit: 255
    t.string   "social_icons",              limit: 255
    t.string   "facebook_link",             limit: 255
    t.string   "google_plus_link",          limit: 255
    t.string   "linkedin_link",             limit: 255
    t.string   "twitter_link",              limit: 255
    t.text     "body",                      limit: 16777215
    t.string   "custom_code",               limit: 255
    t.string   "need_registration_form",    limit: 255
    t.string   "field1",                    limit: 255
    t.string   "field2",                    limit: 255
    t.string   "field3",                    limit: 255
    t.string   "field4",                    limit: 255
    t.string   "field5",                    limit: 255
    t.integer  "event_id",                  limit: 4
    t.text     "micro_url",                 limit: 16777215
    t.string   "header_color",              limit: 255
    t.string   "footer_color",              limit: 255
    t.string   "website_name",              limit: 255
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  create_table "mobile_applications", force: :cascade do |t|
    t.string   "name",                                               limit: 255
    t.string   "application_type",                                   limit: 255
    t.integer  "client_id",                                          limit: 4
    t.datetime "created_at",                                                                          null: false
    t.datetime "updated_at",                                                                          null: false
    t.string   "app_icon_file_name",                                 limit: 255
    t.string   "app_icon_content_type",                              limit: 255
    t.integer  "app_icon_file_size",                                 limit: 4
    t.datetime "app_icon_updated_at"
    t.string   "splash_screen_file_name",                            limit: 255
    t.string   "splash_screen_content_type",                         limit: 255
    t.integer  "splash_screen_file_size",                            limit: 4
    t.datetime "splash_screen_updated_at"
    t.string   "login_background_file_name",                         limit: 255
    t.string   "login_background_content_type",                      limit: 255
    t.integer  "login_background_file_size",                         limit: 4
    t.datetime "login_background_updated_at"
    t.string   "listing_screen_background_file_name",                limit: 255
    t.string   "listing_screen_background_content_type",             limit: 255
    t.integer  "listing_screen_background_file_size",                limit: 4
    t.datetime "listing_screen_background_updated_at"
    t.string   "submitted_code",                                     limit: 255
    t.string   "login_at",                                           limit: 255,      default: "Yes"
    t.integer  "template_id",                                        limit: 4
    t.string   "preview_code",                                       limit: 255
    t.string   "status",                                             limit: 255
    t.string   "login_background_color",                             limit: 255
    t.text     "message_above_login_page",                           limit: 16777215
    t.text     "registration_message",                               limit: 16777215
    t.text     "registration_link",                                  limit: 16777215
    t.string   "login_button_color",                                 limit: 255
    t.string   "login_button_text_color",                            limit: 255
    t.string   "listing_screen_text_color",                          limit: 255
    t.string   "social_media_status",                                limit: 255
    t.integer  "parent_id",                                          limit: 4
    t.string   "choose_home_page",                                   limit: 255
    t.integer  "home_page_event_id",                                 limit: 4
    t.string   "visitor_registration",                               limit: 255
    t.string   "visitor_registration_background_color",              limit: 255
    t.string   "visitor_registration_background_image_file_name",    limit: 255
    t.string   "visitor_registration_background_image_content_type", limit: 255
    t.integer  "visitor_registration_background_image_file_size",    limit: 4
    t.datetime "visitor_registration_background_image_updated_at"
    t.string   "social_media_logins",                                limit: 255
    t.string   "android_push_service",                               limit: 255
    t.string   "marketing_app_event_id",                             limit: 255
    t.string   "all_events_listing",                                 limit: 255,      default: "yes"
    t.datetime "event_listing_display_updated_at"
    t.string   "agreeing_terms_and_conditions",                      limit: 255
    t.string   "user_agreement_text",                                limit: 255
    t.string   "url_1_text",                                         limit: 255
    t.string   "url_1_link",                                         limit: 255
    t.string   "url_2_text",                                         limit: 255
    t.string   "url_2_link",                                         limit: 255
  end

  add_index "mobile_applications", ["application_type"], name: "index_on_application_type_in_mobile_applications", length: {"application_type"=>191}, using: :btree
  add_index "mobile_applications", ["client_id"], name: "index_mobile_applications_on_client_id", using: :btree
  add_index "mobile_applications", ["id", "updated_at", "created_at"], name: "index_mobile_applications_on_id_and_updated_at_and_created_at", using: :btree
  add_index "mobile_applications", ["name"], name: "index_name_on_mobile_applications", length: {"name"=>191}, using: :btree
  add_index "mobile_applications", ["parent_id"], name: "index_mobile_applications_on_parent_id", using: :btree
  add_index "mobile_applications", ["submitted_code", "created_at"], name: "index_mobile_applications_on_submitted_code_and_created_at", length: {"submitted_code"=>191, "created_at"=>nil}, using: :btree
  add_index "mobile_applications", ["submitted_code"], name: "index_mobile_applications_on_submitted_code", length: {"submitted_code"=>191}, using: :btree
  add_index "mobile_applications", ["updated_at"], name: "index_on_updated_at_in_mobile_applications", using: :btree

  create_table "my_profiles", force: :cascade do |t|
    t.integer  "event_id",     limit: 4
    t.text     "enabled_attr", limit: 16777215
    t.string   "attr1",        limit: 255
    t.string   "attr2",        limit: 255
    t.string   "attr3",        limit: 255
    t.string   "attr4",        limit: 255
    t.string   "attr5",        limit: 255
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  create_table "my_travel_docs", force: :cascade do |t|
    t.integer  "event_id",                          limit: 4
    t.string   "my_travel_attach_doc_file_name",    limit: 255
    t.string   "my_travel_attach_doc_content_type", limit: 255
    t.integer  "my_travel_attach_doc_file_size",    limit: 4
    t.datetime "my_travel_attach_doc_updated_at"
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
  end

  create_table "my_travels", force: :cascade do |t|
    t.string   "invitee_id",                 limit: 255
    t.integer  "event_id",                   limit: 4
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "attach_file_file_name",      limit: 255
    t.string   "attach_file_content_type",   limit: 255
    t.integer  "attach_file_file_size",      limit: 4
    t.datetime "attach_file_updated_at"
    t.string   "attach_file_1_name",         limit: 255
    t.string   "attach_file_2_file_name",    limit: 255
    t.string   "attach_file_2_content_type", limit: 255
    t.integer  "attach_file_2_file_size",    limit: 4
    t.datetime "attach_file_2_updated_at"
    t.string   "attach_file_2_name",         limit: 255
    t.string   "attach_file_3_file_name",    limit: 255
    t.string   "attach_file_3_content_type", limit: 255
    t.integer  "attach_file_3_file_size",    limit: 4
    t.datetime "attach_file_3_updated_at"
    t.string   "attach_file_3_name",         limit: 255
    t.string   "attach_file_4_file_name",    limit: 255
    t.string   "attach_file_4_content_type", limit: 255
    t.integer  "attach_file_4_file_size",    limit: 4
    t.datetime "attach_file_4_updated_at"
    t.string   "attach_file_4_name",         limit: 255
    t.string   "attach_file_5_file_name",    limit: 255
    t.string   "attach_file_5_content_type", limit: 255
    t.integer  "attach_file_5_file_size",    limit: 4
    t.datetime "attach_file_5_updated_at"
    t.string   "attach_file_5_name",         limit: 255
    t.string   "comment_box",                limit: 255
    t.string   "event_timezone",             limit: 255
    t.integer  "parent_id",                  limit: 4
    t.string   "event_timezone_offset",      limit: 255
    t.string   "event_display_time_zone",    limit: 255
  end

  add_index "my_travels", ["event_id"], name: "index_my_travels_on_event_id", using: :btree
  add_index "my_travels", ["parent_id"], name: "index_my_travels_on_parent_id", using: :btree

  create_table "notes", force: :cascade do |t|
    t.text     "description",    limit: 16777215
    t.datetime "date"
    t.integer  "event_id",       limit: 4
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "event_timezone", limit: 255
  end

  add_index "notes", ["event_id"], name: "index_notes_on_event_id", using: :btree

  create_table "notifications", force: :cascade do |t|
    t.string   "action",                                   limit: 255
    t.integer  "sender_id",                                limit: 4
    t.datetime "created_at",                                                                  null: false
    t.datetime "updated_at",                                                                  null: false
    t.text     "description",                              limit: 16777215
    t.string   "push_page",                                limit: 255
    t.integer  "page_id",                                  limit: 4
    t.datetime "push_datetime"
    t.integer  "event_id",                                 limit: 4
    t.boolean  "pushed",                                   limit: 1,        default: false
    t.text     "group_ids",                                limit: 16777215
    t.string   "image_file_name",                          limit: 255
    t.string   "image_content_type",                       limit: 255
    t.integer  "image_file_size",                          limit: 4
    t.datetime "image_updated_at"
    t.string   "notification_type",                        limit: 255
    t.string   "open",                                     limit: 255,      default: "false"
    t.string   "unread",                                   limit: 255,      default: "true"
    t.string   "event_timezone",                           limit: 255
    t.string   "event_timezone_offset",                    limit: 255
    t.string   "event_display_time_zone",                  limit: 255
    t.boolean  "push",                                     limit: 1
    t.boolean  "show_on_notification_screen",              limit: 1
    t.boolean  "show_on_activity",                         limit: 1
    t.string   "image_for_show_notification_file_name",    limit: 255
    t.string   "image_for_show_notification_content_type", limit: 255
    t.integer  "image_for_show_notification_file_size",    limit: 4
    t.datetime "image_for_show_notification_updated_at"
    t.string   "actionable_id",                            limit: 255
  end

  add_index "notifications", ["created_at"], name: "index_created_at_on_notifications", using: :btree
  add_index "notifications", ["event_id"], name: "index_faqs_on_event_id", using: :btree
  add_index "notifications", ["page_id"], name: "index_notifications_on_page_id", using: :btree
  add_index "notifications", ["push_datetime"], name: "index_on_push_datetime_in_notifications", using: :btree
  add_index "notifications", ["pushed", "event_id"], name: "index_notifications_on_events_index", using: :btree
  add_index "notifications", ["pushed", "push_datetime"], name: "index_pushed_date_time_on_notifications", using: :btree
  add_index "notifications", ["pushed"], name: "index_on_pushed_in_notifications", using: :btree
  add_index "notifications", ["updated_at", "event_id", "pushed", "show_on_notification_screen", "created_at"], name: "index_noti_on_updtd_at_event_id_pushed_show_on_noti_crtd_at", using: :btree
  add_index "notifications", ["updated_at"], name: "index_on_updated_at_in_notifications", using: :btree

  create_table "panels", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.integer  "event_id",      limit: 4
    t.integer  "panel_id",      limit: 4
    t.string   "panel_type",    limit: 255
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.string   "speaker_name",  limit: 255
    t.integer  "sequence",      limit: 4
    t.string   "speaker_email", limit: 255
    t.string   "hide_panel",    limit: 255, default: "deactive"
  end

  add_index "panels", ["event_id"], name: "index_panels_on_event_id", using: :btree
  add_index "panels", ["panel_id"], name: "index_panels_on_panel_id", using: :btree
  add_index "panels", ["updated_at", "event_id", "sequence"], name: "index_panels_on_updated_at_and_event_id_and_sequence", using: :btree

  create_table "poll_walls", force: :cascade do |t|
    t.string   "background_color",              limit: 255
    t.string   "bar_color",                     limit: 255
    t.string   "font_color",                    limit: 255
    t.string   "bar_color1",                    limit: 255
    t.integer  "event_id",                      limit: 4
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.string   "logo_file_name",                limit: 255
    t.string   "logo_content_type",             limit: 255
    t.integer  "logo_file_size",                limit: 4
    t.datetime "logo_updated_at"
    t.string   "background_image_file_name",    limit: 255
    t.string   "background_image_content_type", limit: 255
    t.integer  "background_image_file_size",    limit: 4
    t.datetime "background_image_updated_at"
    t.string   "sub_text_color",                limit: 255
  end

  create_table "polls", force: :cascade do |t|
    t.text     "question",                limit: 16777215
    t.string   "option1",                 limit: 255
    t.string   "option2",                 limit: 255
    t.string   "option3",                 limit: 255
    t.string   "option4",                 limit: 255
    t.string   "option5",                 limit: 255
    t.string   "option6",                 limit: 255
    t.integer  "event_id",                limit: 4
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
    t.datetime "poll_start_date_time"
    t.datetime "poll_end_date_time"
    t.string   "status",                  limit: 255
    t.float    "sequence",                limit: 24
    t.datetime "poll_start_time"
    t.datetime "poll_end_time"
    t.string   "on_wall",                 limit: 255
    t.string   "option_visible",          limit: 255,      default: "yes"
    t.string   "event_timezone",          limit: 255
    t.string   "option_type",             limit: 255
    t.boolean  "description",             limit: 1
    t.string   "option7",                 limit: 255
    t.string   "option8",                 limit: 255
    t.string   "option9",                 limit: 255
    t.string   "option010",               limit: 255
    t.string   "rating_first_text",       limit: 255
    t.string   "rating_second_text",      limit: 255
    t.string   "event_timezone_offset",   limit: 255
    t.string   "event_display_time_zone", limit: 255
    t.string   "wall_type",               limit: 255
    t.datetime "last_force_destroyed"
    t.string   "select_session",          limit: 255
    t.string   "show_poll_at",            limit: 255
  end

  add_index "polls", ["event_id"], name: "index_polls_on_event_id", using: :btree
  add_index "polls", ["question"], name: "index_on_question_in_polls", length: {"question"=>191}, using: :btree
  add_index "polls", ["sequence"], name: "index_sequence_on_polls", using: :btree
  add_index "polls", ["status"], name: "index_status_on_polls", length: {"status"=>191}, using: :btree

  create_table "push_notifications", force: :cascade do |t|
    t.text     "description",   limit: 16777215
    t.string   "page",          limit: 255
    t.integer  "page_id",       limit: 4
    t.datetime "push_datetime"
    t.integer  "event_id",      limit: 4
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.boolean  "pushed",        limit: 1,        default: false
  end

  create_table "push_pem_files", force: :cascade do |t|
    t.integer  "mobile_application_id", limit: 4
    t.string   "title",                 limit: 255
    t.string   "pass_phrase",           limit: 255
    t.string   "push_url",              limit: 255
    t.text     "android_push_key",      limit: 16777215
    t.string   "pem_file_file_name",    limit: 255
    t.string   "pem_file_content_type", limit: 255
    t.integer  "pem_file_file_size",    limit: 4
    t.datetime "pem_file_updated_at"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  add_index "push_pem_files", ["mobile_application_id"], name: "index_mobile_id_on_push_pem_files", using: :btree

  create_table "qna_settings", force: :cascade do |t|
    t.integer  "event_id",           limit: 4
    t.string   "display_qna_on_app", limit: 255
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  create_table "qna_walls", force: :cascade do |t|
    t.integer  "event_id",                      limit: 4
    t.string   "bg_color",                      limit: 255
    t.string   "tab_color",                     limit: 255
    t.string   "font_color",                    limit: 255
    t.string   "title",                         limit: 255
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.string   "logo_file_name",                limit: 255
    t.string   "logo_content_type",             limit: 255
    t.integer  "logo_file_size",                limit: 4
    t.datetime "logo_updated_at"
    t.string   "background_image_file_name",    limit: 255
    t.string   "background_image_content_type", limit: 255
    t.integer  "background_image_file_size",    limit: 4
    t.datetime "background_image_updated_at"
    t.string   "title_color",                   limit: 255
    t.string   "sub_text_color",                limit: 255
  end

  create_table "qnas", force: :cascade do |t|
    t.text     "question",                limit: 16777215
    t.text     "answer",                  limit: 16777215
    t.integer  "sender_id",               limit: 4
    t.integer  "receiver_id",             limit: 4
    t.integer  "event_id",                limit: 4
    t.string   "status",                  limit: 255,      default: "pending"
    t.datetime "created_at",                                                   null: false
    t.datetime "updated_at",                                                   null: false
    t.string   "on_wall",                 limit: 255
    t.string   "wall_answer",             limit: 255
    t.string   "event_timezone",          limit: 255
    t.string   "anonymous_on_wall",       limit: 255,      default: "false"
    t.string   "event_timezone_offset",   limit: 255
    t.string   "event_display_time_zone", limit: 255
    t.datetime "last_force_destroyed"
    t.string   "user_answered",           limit: 255,      default: "no"
  end

  add_index "qnas", ["event_id"], name: "index_qnas_on_event_id", using: :btree
  add_index "qnas", ["question"], name: "index_on_question_in_qnas", length: {"question"=>191}, using: :btree
  add_index "qnas", ["receiver_id"], name: "index_receiver_id_on_qnas", using: :btree
  add_index "qnas", ["sender_id"], name: "index_sender_id_on_qnas", using: :btree
  add_index "qnas", ["status"], name: "index_status_on_qnas", length: {"status"=>191}, using: :btree
  add_index "qnas", ["updated_at", "event_id", "created_at"], name: "index_qnas_on_updated_at_and_event_id_and_created_at", using: :btree

  create_table "quiz_walls", force: :cascade do |t|
    t.string   "background_color",              limit: 255
    t.string   "bar_color",                     limit: 255
    t.string   "font_color",                    limit: 255
    t.integer  "event_id",                      limit: 4
    t.string   "bar_color1",                    limit: 255
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.string   "logo_file_name",                limit: 255
    t.string   "logo_content_type",             limit: 255
    t.integer  "logo_file_size",                limit: 4
    t.datetime "logo_updated_at"
    t.string   "background_image_file_name",    limit: 255
    t.string   "background_image_content_type", limit: 255
    t.integer  "background_image_file_size",    limit: 4
    t.datetime "background_image_updated_at"
    t.string   "sub_text_color",                limit: 255
  end

  create_table "quizzes", force: :cascade do |t|
    t.text     "question",                 limit: 16777215
    t.string   "option1",                  limit: 255
    t.string   "option2",                  limit: 255
    t.string   "option3",                  limit: 255
    t.string   "option4",                  limit: 255
    t.string   "option5",                  limit: 255
    t.string   "option6",                  limit: 255
    t.string   "status",                   limit: 255
    t.string   "sequence",                 limit: 255
    t.integer  "event_id",                 limit: 4
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.string   "correct_answer",           limit: 255
    t.string   "event_timezone",           limit: 255
    t.string   "event_timezone_offset",    limit: 255
    t.string   "event_display_time_zone",  limit: 255
    t.string   "on_wall",                  limit: 255
    t.datetime "last_force_destroyed"
    t.integer  "user_quizzes_count_cache", limit: 4,        default: 0
  end

  add_index "quizzes", ["event_id"], name: "index_on_event_id_in_quizzes", using: :btree
  add_index "quizzes", ["question"], name: "index_on_question_in_quizzes", length: {"question"=>191}, using: :btree

  create_table "ratings", force: :cascade do |t|
    t.integer  "ratable_id",   limit: 4
    t.string   "ratable_type", limit: 255
    t.float    "rating",       limit: 24
    t.integer  "out_of",       limit: 4
    t.text     "comments",     limit: 16777215
    t.integer  "rated_by",     limit: 4
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "ratings", ["ratable_id", "updated_at"], name: "index_ratings_on_events_index", using: :btree
  add_index "ratings", ["ratable_id"], name: "index_on_ratable_id_in_ratings", using: :btree
  add_index "ratings", ["ratable_type"], name: "index_on_ratable_type_in_ratings", length: {"ratable_type"=>191}, using: :btree
  add_index "ratings", ["rated_by"], name: "index_on_rated_by_in_ratings", using: :btree
  add_index "ratings", ["updated_at"], name: "index_on_updated_at_in_ratings", using: :btree

  create_table "registration_look_and_feels", force: :cascade do |t|
    t.integer  "event_id",                           limit: 4
    t.string   "logo_file_name",                     limit: 255
    t.string   "logo_content_type",                  limit: 255
    t.integer  "logo_file_size",                     limit: 4
    t.datetime "logo_updated_at"
    t.string   "logo_alignment",                     limit: 255
    t.string   "logo_back_color",                    limit: 255
    t.string   "banner_image_file_name",             limit: 255
    t.string   "banner_image_content_type",          limit: 255
    t.integer  "banner_image_file_size",             limit: 4
    t.datetime "banner_image_updated_at"
    t.text     "header_formatter",                   limit: 65535
    t.string   "page_font_style",                    limit: 255
    t.string   "header_font_size",                   limit: 255
    t.string   "body_font_size",                     limit: 255
    t.string   "body_background_image_file_name",    limit: 255
    t.string   "body_background_image_content_type", limit: 255
    t.integer  "body_background_image_file_size",    limit: 4
    t.datetime "body_background_image_updated_at"
    t.string   "body_background_color",              limit: 255
    t.string   "button_color",                       limit: 255
    t.text     "footer_formatter",                   limit: 65535
    t.string   "footer_image_file_name",             limit: 255
    t.string   "footer_image_content_type",          limit: 255
    t.integer  "footer_image_file_size",             limit: 4
    t.datetime "footer_image_updated_at"
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.text     "registration_form_header",           limit: 65535
    t.string   "button_font_color",                  limit: 255
    t.string   "button_text",                        limit: 255
    t.string   "page_font",                          limit: 255
  end

  create_table "registration_settings", force: :cascade do |t|
    t.string   "external_reg",                    limit: 255
    t.text     "reg_url",                         limit: 16777215
    t.text     "reg_surl",                        limit: 16777215
    t.string   "external_login",                  limit: 255
    t.text     "login_url",                       limit: 16777215
    t.text     "login_surl",                      limit: 16777215
    t.text     "forget_pass_url",                 limit: 16777215
    t.text     "forget_pass_surl",                limit: 16777215
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.integer  "event_id",                        limit: 4
    t.string   "registration",                    limit: 255
    t.string   "login",                           limit: 255
    t.string   "response_type",                   limit: 255
    t.text     "external_reg_url",                limit: 16777215
    t.text     "external_reg_surl",               limit: 16777215
    t.text     "external_login_url",              limit: 16777215
    t.text     "external_login_surl",             limit: 16777215
    t.string   "template",                        limit: 255
    t.string   "on_mobile_app",                   limit: 255
    t.datetime "start_date"
    t.datetime "end_date"
    t.string   "auto_approved",                   limit: 255
    t.integer  "parent_id",                       limit: 4
    t.string   "auto_rejected",                   limit: 255
    t.text     "auto_rejected_domain_validation", limit: 65535
    t.text     "auto_approved_domain_validation", limit: 65535
    t.string   "target_registration",             limit: 255
    t.integer  "target_attendees",                limit: 4
    t.text     "submit_msg",                      limit: 65535
  end

  add_index "registration_settings", ["parent_id"], name: "index_registration_settings_on_parent_id", using: :btree

  create_table "registrations", force: :cascade do |t|
    t.integer  "event_id",           limit: 4
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.text     "field1",             limit: 4294967295
    t.text     "field2",             limit: 4294967295
    t.text     "field3",             limit: 4294967295
    t.text     "field4",             limit: 4294967295
    t.text     "field5",             limit: 4294967295
    t.text     "field6",             limit: 4294967295
    t.text     "field7",             limit: 4294967295
    t.text     "field8",             limit: 4294967295
    t.text     "field9",             limit: 4294967295
    t.text     "field10",            limit: 4294967295
    t.text     "field11",            limit: 4294967295
    t.text     "field12",            limit: 4294967295
    t.text     "field13",            limit: 4294967295
    t.text     "field14",            limit: 4294967295
    t.text     "field15",            limit: 4294967295
    t.text     "field16",            limit: 4294967295
    t.text     "field17",            limit: 4294967295
    t.text     "field18",            limit: 4294967295
    t.text     "field19",            limit: 4294967295
    t.text     "field20",            limit: 4294967295
    t.text     "custom_css",         limit: 4294967295
    t.text     "custom_js",          limit: 4294967295
    t.text     "custom_source_code", limit: 4294967295
    t.string   "email_field",        limit: 255
    t.integer  "parent_id",          limit: 4
  end

  add_index "registrations", ["parent_id"], name: "index_registrations_on_parent_id", using: :btree

  create_table "roles", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.integer  "resource_id",   limit: 4
    t.string   "resource_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", length: {"name"=>191, "resource_type"=>191, "resource_id"=>nil}, using: :btree
  add_index "roles", ["name"], name: "index_roles_on_name", length: {"name"=>191}, using: :btree

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", limit: 255,   null: false
    t.text     "data",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "smtp_settings", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.string   "username",   limit: 255
    t.string   "password",   limit: 255
    t.string   "domain",     limit: 255
    t.string   "address",    limit: 255
    t.string   "from_email", limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "port",       limit: 255
  end

  create_table "speakers", force: :cascade do |t|
    t.string   "event_name",               limit: 255
    t.string   "speaker_name",             limit: 255
    t.string   "designation",              limit: 255
    t.string   "email_address",            limit: 255
    t.text     "address",                  limit: 16777215
    t.text     "speaker_info",             limit: 16777215
    t.string   "rating",                   limit: 255
    t.text     "feedback",                 limit: 16777215
    t.integer  "event_id",                 limit: 4
    t.datetime "created_at",                                                   null: false
    t.datetime "updated_at",                                                   null: false
    t.string   "phone_no",                 limit: 255
    t.string   "profile_pic_file_name",    limit: 255
    t.string   "profile_pic_content_type", limit: 255
    t.integer  "profile_pic_file_size",    limit: 4
    t.datetime "profile_pic_updated_at"
    t.string   "company",                  limit: 255
    t.string   "is_answerable",            limit: 255
    t.float    "sequence",                 limit: 24
    t.string   "rating_status",            limit: 255,      default: "active"
    t.string   "first_name",               limit: 255
    t.string   "last_name",                limit: 255
    t.string   "event_timezone",           limit: 255
    t.integer  "parent_id",                limit: 4
    t.string   "event_timezone_offset",    limit: 255
    t.string   "event_display_time_zone",  limit: 255
    t.string   "all_agenda_ids",           limit: 255
    t.integer  "ratings_count_cache",      limit: 4
    t.string   "course_ids",               limit: 255
    t.datetime "last_force_destroyed"
  end

  add_index "speakers", ["designation"], name: "index_designation_on_speakers", length: {"designation"=>191}, using: :btree
  add_index "speakers", ["email_address"], name: "index_email_address_on_speakers", length: {"email_address"=>191}, using: :btree
  add_index "speakers", ["event_id", "sequence"], name: "index_speakers_on_event_id_and_sequence", using: :btree
  add_index "speakers", ["event_id"], name: "index_speakers_on_event_id", using: :btree
  add_index "speakers", ["parent_id"], name: "index_speakers_on_parent_id", using: :btree
  add_index "speakers", ["sequence"], name: "index_sequence_on_speakers", using: :btree
  add_index "speakers", ["speaker_name"], name: "index_speaker_name_on_speakers", length: {"speaker_name"=>191}, using: :btree
  add_index "speakers", ["updated_at", "event_id"], name: "index_speakers_on_updated_at_and_event_id", using: :btree

  create_table "sponsors", force: :cascade do |t|
    t.integer  "event_id",             limit: 4
    t.string   "sponsor_type",         limit: 255
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.string   "name",                 limit: 255
    t.string   "email",                limit: 255
    t.text     "description",          limit: 16777215
    t.text     "website_url",          limit: 16777215
    t.integer  "sequence",             limit: 4
    t.string   "logo_file_name",       limit: 255
    t.string   "logo_content_type",    limit: 255
    t.integer  "logo_file_size",       limit: 4
    t.datetime "logo_updated_at"
    t.integer  "parent_id",            limit: 4
    t.string   "mobile",               limit: 255
    t.string   "contact_person_name",  limit: 255
    t.datetime "last_force_destroyed"
  end

  add_index "sponsors", ["event_id"], name: "index_sponsors_on_event_id", using: :btree
  add_index "sponsors", ["parent_id"], name: "index_sponsors_on_parent_id", using: :btree
  add_index "sponsors", ["sponsor_type"], name: "index_sponsor_type_on_sponsors", length: {"sponsor_type"=>191}, using: :btree

  create_table "store_infos", force: :cascade do |t|
    t.string   "mobile_application_id",         limit: 255
    t.string   "is_android_app",                limit: 255
    t.string   "is_ios_app",                    limit: 255
    t.string   "android_title",                 limit: 255
    t.string   "android_short_desc",            limit: 255
    t.text     "android_full_desc",             limit: 16777215
    t.string   "android_app_type",              limit: 255
    t.string   "android_category",              limit: 255
    t.string   "android_content_rating",        limit: 255
    t.string   "android_website",               limit: 255
    t.string   "android_email",                 limit: 255
    t.string   "android_phone",                 limit: 255
    t.text     "android_policy_url",            limit: 16777215
    t.text     "android_country_list",          limit: 16777215
    t.string   "android_contains_ads",          limit: 255
    t.string   "android_content_guideline",     limit: 255
    t.string   "android_us_export_laws",        limit: 255
    t.string   "android_app_icon_file_name",    limit: 255
    t.string   "android_app_icon_content_type", limit: 255
    t.integer  "android_app_icon_file_size",    limit: 4
    t.datetime "android_app_icon_updated_at"
    t.string   "ios_title",                     limit: 255
    t.string   "ios_language",                  limit: 255
    t.string   "ios_bundle_id",                 limit: 255
    t.string   "ios_sku",                       limit: 255
    t.string   "ios_keyword",                   limit: 255
    t.string   "ios_support_url",               limit: 255
    t.string   "ios_copyright",                 limit: 255
    t.string   "ios_contact_first_name",        limit: 255
    t.string   "ios_contact_last_name",         limit: 255
    t.string   "ios_contact_email",             limit: 255
    t.string   "ios_contact_phone",             limit: 255
    t.string   "ios_demo_email",                limit: 255
    t.string   "ios_password",                  limit: 255
    t.text     "ios_notes",                     limit: 16777215
    t.string   "ios_app_icon_file_name",        limit: 255
    t.string   "ios_app_icon_content_type",     limit: 255
    t.integer  "ios_app_icon_file_size",        limit: 4
    t.datetime "ios_app_icon_updated_at"
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.string   "published_by_hobnob",           limit: 255
  end

  create_table "store_screenshots", force: :cascade do |t|
    t.integer  "store_info_id",       limit: 4
    t.string   "platform",            limit: 255
    t.string   "screen_type",         limit: 255
    t.string   "screen_name",         limit: 255
    t.string   "screen_size",         limit: 255
    t.string   "screen_file_name",    limit: 255
    t.string   "screen_content_type", limit: 255
    t.integer  "screen_file_size",    limit: 4
    t.datetime "screen_updated_at"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id",        limit: 4
    t.integer  "taggable_id",   limit: 4
    t.string   "taggable_type", limit: 255
    t.integer  "tagger_id",     limit: 4
    t.string   "tagger_type",   limit: 255
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name",           limit: 255
    t.integer "taggings_count", limit: 4,   default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "telecaller_accessible_columns", force: :cascade do |t|
    t.text     "accessible_attribute", limit: 16777215
    t.integer  "event_id",             limit: 4
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_index "telecaller_accessible_columns", ["event_id"], name: "index_telecaller_accessible_columns_on_event_id", using: :btree

  create_table "telecaller_groups", force: :cascade do |t|
    t.string   "assign_grouping",     limit: 255
    t.integer  "target_assigned",     limit: 4
    t.integer  "registration_target", limit: 4
    t.integer  "event_id",            limit: 4
    t.integer  "user_id",             limit: 4
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  create_table "themes", force: :cascade do |t|
    t.integer  "licensee_id",                         limit: 4
    t.string   "name",                                limit: 255
    t.string   "background_color",                    limit: 255
    t.string   "skin_image",                          limit: 255
    t.string   "content_font_color",                  limit: 255
    t.string   "button_color",                        limit: 255
    t.string   "button_content_color",                limit: 255
    t.string   "drawer_menu_back_color",              limit: 255
    t.string   "drawer_menu_font_color",              limit: 255
    t.datetime "created_at",                                                     null: false
    t.datetime "updated_at",                                                     null: false
    t.string   "bar_color",                           limit: 255
    t.string   "event_background_image_file_name",    limit: 255
    t.string   "event_background_image_content_type", limit: 255
    t.integer  "event_background_image_file_size",    limit: 4
    t.datetime "event_background_image_updated_at"
    t.boolean  "licensee_theme",                      limit: 1
    t.integer  "created_by",                          limit: 4
    t.string   "header_color",                        limit: 255
    t.string   "footer_color",                        limit: 255
    t.boolean  "admin_theme",                         limit: 1
    t.string   "preview_theme",                       limit: 255, default: "no"
    t.datetime "last_force_destroyed"
  end

  add_index "themes", ["admin_theme"], name: "index_on_admin_theme_in_themes", using: :btree
  add_index "themes", ["licensee_id"], name: "index_themes_on_licensee_id", using: :btree
  add_index "themes", ["licensee_theme"], name: "index_licensee_theme_on_themes", using: :btree
  add_index "themes", ["name"], name: "index_name_on_themes", length: {"name"=>191}, using: :btree
  add_index "themes", ["preview_theme"], name: "index_on_preview_theme_in_themes", length: {"preview_theme"=>191}, using: :btree
  add_index "themes", ["updated_at"], name: "index_themes_on_updated_at", using: :btree

  create_table "track_links", force: :cascade do |t|
    t.integer  "event_id",        limit: 4
    t.integer  "edm_id",          limit: 4
    t.string   "redirect_link",   limit: 255
    t.string   "regenerate_link", limit: 255
    t.string   "link_count",      limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "unsubscribes", force: :cascade do |t|
    t.integer  "event_id",    limit: 4
    t.integer  "edm_id",      limit: 4
    t.string   "email",       limit: 255
    t.string   "unsubscribe", limit: 255, default: "false"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
  end

  create_table "user_feedbacks", force: :cascade do |t|
    t.integer  "feedback_id",      limit: 4
    t.integer  "user_id",          limit: 4
    t.string   "answer",           limit: 255
    t.text     "description",      limit: 16777215
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "feedback_form_id", limit: 4
  end

  add_index "user_feedbacks", ["feedback_id", "updated_at"], name: "index_user_feedbacks_on_events_index", using: :btree
  add_index "user_feedbacks", ["feedback_id", "user_id"], name: "index_user_feedbacks_on_api", using: :btree
  add_index "user_feedbacks", ["feedback_id"], name: "index_user_feedbacks_on_feedback_id", using: :btree
  add_index "user_feedbacks", ["user_id"], name: "index_user_feedbacks_on_user_id", using: :btree

  create_table "user_microsites", force: :cascade do |t|
    t.string   "event_id",   limit: 255
    t.string   "field1",     limit: 255
    t.string   "field2",     limit: 255
    t.string   "field3",     limit: 255
    t.string   "field4",     limit: 255
    t.string   "field5",     limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "user_polls", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "poll_id",    limit: 4
    t.text     "answer",     limit: 16777215
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "user_polls", ["poll_id", "updated_at"], name: "index_user_polls_on_events_index", using: :btree
  add_index "user_polls", ["poll_id"], name: "index_user_polls_on_poll_id", using: :btree
  add_index "user_polls", ["user_id"], name: "index_user_polls_on_user_id", using: :btree

  create_table "user_quizzes", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "quiz_id",    limit: 4
    t.string   "answer",     limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "user_quizzes", ["quiz_id", "updated_at"], name: "index_user_quizzes_on_events_index", using: :btree
  add_index "user_quizzes", ["quiz_id"], name: "index_user_quizzes_on_quiz_id", using: :btree
  add_index "user_quizzes", ["user_id"], name: "index_user_quizzes_on_user_id", using: :btree

  create_table "user_registrations", force: :cascade do |t|
    t.integer  "registration_id",                      limit: 4
    t.integer  "invitee_id",                           limit: 4
    t.integer  "event_id",                             limit: 4
    t.string   "field1",                               limit: 255
    t.string   "field2",                               limit: 255
    t.string   "field3",                               limit: 255
    t.string   "field4",                               limit: 255
    t.string   "field5",                               limit: 255
    t.string   "field6",                               limit: 255
    t.string   "field7",                               limit: 255
    t.string   "field8",                               limit: 255
    t.string   "field9",                               limit: 255
    t.string   "field10",                              limit: 255
    t.string   "field11",                              limit: 255
    t.string   "field12",                              limit: 255
    t.string   "field13",                              limit: 255
    t.string   "field14",                              limit: 255
    t.string   "field15",                              limit: 255
    t.datetime "created_at",                                                            null: false
    t.datetime "updated_at",                                                            null: false
    t.text     "field16",                              limit: 16777215
    t.text     "field17",                              limit: 16777215
    t.text     "field18",                              limit: 16777215
    t.text     "field19",                              limit: 16777215
    t.text     "field20",                              limit: 16777215
    t.string   "text_box_for_checkbox_or_radiobutton", limit: 255
    t.string   "status",                               limit: 255
    t.integer  "parent_id",                            limit: 4
    t.string   "unique_confirmation_code",             limit: 255
    t.string   "qr_code_file_name",                    limit: 255
    t.string   "qr_code_content_type",                 limit: 255
    t.integer  "qr_code_file_size",                    limit: 4
    t.datetime "qr_code_updated_at"
    t.string   "rfid",                                 limit: 255
    t.boolean  "event_kit",                            limit: 1,        default: false
    t.boolean  "gift",                                 limit: 1,        default: false
    t.text     "comment",                              limit: 65535
    t.boolean  "walk_in_registration",                 limit: 1,        default: false
    t.string   "registration_type",                    limit: 255
  end

  add_index "user_registrations", ["parent_id"], name: "index_user_registrations_on_parent_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "first_name",                 limit: 255
    t.string   "last_name",                  limit: 255
    t.string   "username",                   limit: 255
    t.string   "pin_code",                   limit: 255
    t.string   "mobile",                     limit: 255
    t.string   "email",                      limit: 255, default: "",       null: false
    t.string   "encrypted_password",         limit: 255, default: "",       null: false
    t.string   "reset_password_token",       limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",              limit: 4,   default: 0,        null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",         limit: 255
    t.string   "last_sign_in_ip",            limit: 255
    t.string   "confirmation_token",         limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email",          limit: 255
    t.datetime "created_at",                                                null: false
    t.datetime "updated_at",                                                null: false
    t.string   "device_token",               limit: 255
    t.string   "key",                        limit: 255
    t.string   "secret_key",                 limit: 255
    t.string   "device_type",                limit: 255
    t.string   "authentication_token",       limit: 255
    t.boolean  "license",                    limit: 1
    t.integer  "licensee_id",                limit: 4
    t.string   "status",                     limit: 255
    t.string   "company",                    limit: 255
    t.string   "package_type",               limit: 255
    t.datetime "licensee_start_date"
    t.datetime "licensee_end_date"
    t.integer  "badge_count",                limit: 4
    t.integer  "client_id",                  limit: 4
    t.string   "designation",                limit: 255
    t.string   "licensee_logo_file_name",    limit: 255
    t.string   "licensee_logo_content_type", limit: 255
    t.integer  "licensee_logo_file_size",    limit: 4
    t.datetime "licensee_logo_updated_at"
    t.integer  "no_of_event",                limit: 4
    t.string   "deleted",                    limit: 255, default: "false"
    t.string   "telecaller",                 limit: 255
    t.string   "assign_grouping",            limit: 255
    t.datetime "last_seen_at"
    t.integer  "target_assigned",            limit: 4
    t.integer  "registration_target",        limit: 4
    t.string   "telecaller_status",          limit: 255, default: "active"
    t.string   "activate_mobile_app",        limit: 255
    t.string   "activate_ems",               limit: 255
  end

  add_index "users", ["authentication_token"], name: "index_on_authentication_token_in_users", using: :btree
  add_index "users", ["client_id"], name: "index_client_id_on_users", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["first_name", "email"], name: "index_first_name_email_on_users", using: :btree
  add_index "users", ["first_name"], name: "index_first_name_on_users", using: :btree
  add_index "users", ["licensee_id"], name: "index_licensee_id_on_users", using: :btree
  add_index "users", ["package_type"], name: "index_package_type_on_users", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["status"], name: "index_status_on_users", using: :btree

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "user_id", limit: 4
    t.integer "role_id", limit: 4
  end

  add_index "users_roles", ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree

  create_table "venue_sections", force: :cascade do |t|
    t.integer  "event_id",       limit: 4
    t.string   "name",           limit: 255
    t.string   "default_access", limit: 255, default: "no"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
  end

  create_table "winners", force: :cascade do |t|
    t.integer  "award_id",   limit: 4
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "sequence",   limit: 4
    t.integer  "parent_id",  limit: 4
  end

  add_index "winners", ["award_id", "updated_at", "sequence"], name: "index_winners_on_award_id_and_updated_at_and_sequence", using: :btree
  add_index "winners", ["award_id", "updated_at"], name: "index_winners_on_award_id_and_updated_at", using: :btree
  add_index "winners", ["award_id"], name: "index_winners_on_award_id", using: :btree
  add_index "winners", ["name"], name: "index_name_on_winners", length: {"name"=>191}, using: :btree
  add_index "winners", ["parent_id"], name: "index_winners_on_parent_id", using: :btree
  add_index "winners", ["updated_at"], name: "index_winners_on_events_index", using: :btree

  add_foreign_key "agendas", "events"
  add_foreign_key "attendees", "events"
  add_foreign_key "invitees", "events"
  add_foreign_key "my_travels", "events"
  add_foreign_key "speakers", "events"
  add_foreign_key "telecaller_accessible_columns", "events"
end
