# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_06_10_193827) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "account_licenses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.string "current_state", default: "pending", null: false
    t.datetime "license_activated_at"
    t.datetime "license_expires_at"
    t.uuid "license_id", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_account_licenses_on_account_id", unique: true
    t.index ["license_id"], name: "index_account_licenses_on_license_id"
  end

  create_table "account_licenses_transitions", force: :cascade do |t|
    t.uuid "account_license_id", null: false
    t.datetime "created_at", null: false
    t.text "metadata", default: "{}"
    t.boolean "most_recent", default: true, null: false
    t.integer "sort_key", null: false
    t.string "to_state", null: false
    t.datetime "updated_at", null: false
    t.index ["account_license_id", "sort_key"], name: "idx_on_account_license_id_sort_key_13c9b15342", unique: true
  end

  create_table "accounts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "current_state", default: "pending", null: false
    t.string "password", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.string "username", null: false
    t.index ["user_id"], name: "index_accounts_on_user_id"
    t.index ["username"], name: "index_accounts_on_username", unique: true
  end

  create_table "accounts_transitions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.datetime "created_at", null: false
    t.text "metadata", default: "{}"
    t.boolean "most_recent", default: true, null: false
    t.integer "sort_key", null: false
    t.string "to_state", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "sort_key"], name: "index_accounts_transitions_on_account_id_and_sort_key", unique: true
  end

  create_table "active_storage_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.uuid "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "app_account_transitions", force: :cascade do |t|
    t.uuid "app_account_id", null: false
    t.datetime "created_at", null: false
    t.text "metadata", default: "{}"
    t.boolean "most_recent", default: true, null: false
    t.integer "sort_key", null: false
    t.string "to_state", null: false
    t.datetime "updated_at", null: false
    t.index ["app_account_id", "sort_key"], name: "index_app_account_transitions_on_app_account_id_and_sort_key", unique: true
  end

  create_table "app_accounts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.uuid "app_demo_id"
    t.uuid "app_id", null: false
    t.uuid "app_purchase_id"
    t.datetime "created_at", null: false
    t.string "current_state", default: "pending", null: false
    t.datetime "ended_at"
    t.datetime "started_at"
    t.datetime "updated_at", null: false
    t.index ["app_id"], name: "index_app_accounts_on_app_id"
  end

  create_table "app_countries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "app_demos", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "app_id", null: false
    t.datetime "created_at", null: false
    t.datetime "started_at"
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
  end

  create_table "app_license_keys", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "app_account_id", null: false
    t.datetime "created_at", null: false
    t.string "key", null: false
    t.datetime "updated_at", null: false
    t.index ["app_account_id"], name: "index_app_license_keys_on_app_account_id"
    t.index ["key"], name: "index_app_license_keys_on_key", unique: true
  end

  create_table "app_purchases", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "app_id", null: false
    t.datetime "created_at", null: false
    t.datetime "purchased_at"
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
  end

  create_table "apps", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "country_id"
    t.datetime "created_at", null: false
    t.boolean "demo", default: false, null: false
    t.text "description"
    t.integer "duration_days", null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.boolean "requires_license_key", default: false, null: false
    t.integer "stock", default: 0, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.string "wiki"
    t.index ["country_id"], name: "index_apps_on_country_id"
  end

  create_table "balance_transitions", force: :cascade do |t|
    t.uuid "balance_id", null: false
    t.datetime "created_at", null: false
    t.text "metadata", default: "{}"
    t.boolean "most_recent", default: true, null: false
    t.integer "sort_key", null: false
    t.string "to_state", null: false
    t.datetime "updated_at", null: false
    t.index ["balance_id", "sort_key"], name: "index_balance_transitions_on_balance_id_and_sort_key", unique: true
  end

  create_table "balances", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["user_id"], name: "index_balances_on_user_id", unique: true
  end

  create_table "browser_account_transitions", force: :cascade do |t|
    t.uuid "browser_account_id", null: false
    t.datetime "created_at", null: false
    t.text "metadata", default: "{}"
    t.boolean "most_recent", default: true, null: false
    t.integer "sort_key", null: false
    t.string "to_state", null: false
    t.datetime "updated_at", null: false
    t.index ["browser_account_id", "sort_key"], name: "idx_on_browser_account_id_sort_key_1aa12f8b84", unique: true
  end

  create_table "browser_accounts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.uuid "browser_purchase_id", null: false
    t.datetime "created_at", null: false
    t.string "current_state", default: "pending", null: false
    t.datetime "ended_at"
    t.datetime "started_at"
    t.datetime "updated_at", null: false
  end

  create_table "browser_purchases", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "browser_id", null: false
    t.datetime "created_at", null: false
    t.integer "device_count", null: false
    t.datetime "purchased_at"
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
  end

  create_table "browsers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "duration_days", null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.string "wiki"
  end

  create_table "bug_report_transitions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "bug_report_id", null: false
    t.datetime "created_at", null: false
    t.text "metadata", default: "{}"
    t.boolean "most_recent", default: true, null: false
    t.integer "sort_key", null: false
    t.string "to_state", null: false
    t.datetime "updated_at", null: false
    t.index ["bug_report_id", "sort_key"], name: "index_bug_report_transitions_on_bug_report_id_and_sort_key", unique: true
  end

  create_table "bug_reports", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "current_state", default: "pending", null: false
    t.text "description", null: false
    t.datetime "processed_at"
    t.uuid "reportable_id", null: false
    t.string "reportable_type", null: false
    t.decimal "reward", precision: 10, scale: 2
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
  end

  create_table "holds", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "amount", null: false
    t.datetime "created_at", null: false
    t.string "current_state", default: "pending", null: false
    t.datetime "expires_at", null: false
    t.string "hold_id", null: false
    t.string "request_id", null: false
    t.datetime "updated_at", null: false
    t.string "user_id", null: false
    t.index ["hold_id"], name: "index_holds_on_hold_id", unique: true
    t.index ["request_id"], name: "index_holds_on_request_id"
    t.index ["user_id", "current_state"], name: "index_holds_on_user_id_and_current_state"
    t.index ["user_id"], name: "index_holds_on_user_id"
  end

  create_table "holds_transitions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "hold_id", null: false
    t.text "metadata", default: "{}"
    t.boolean "most_recent", default: true, null: false
    t.integer "sort_key", null: false
    t.string "to_state", null: false
    t.datetime "updated_at", null: false
    t.index ["hold_id", "sort_key"], name: "index_holds_transitions_on_hold_id_and_sort_key", unique: true
  end

  create_table "invitations", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at"
    t.string "token"
    t.datetime "updated_at", null: false
  end

  create_table "licenses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "duration_days", null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.datetime "updated_at", null: false
  end

  create_table "mobile_order_transitions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "metadata", default: "{}"
    t.uuid "mobile_order_id", null: false
    t.boolean "most_recent", default: true, null: false
    t.integer "sort_key", null: false
    t.string "to_state", null: false
    t.datetime "updated_at", null: false
    t.index ["mobile_order_id", "sort_key"], name: "index_mobile_order_transitions_on_mobile_order_id_and_sort_key", unique: true
  end

  create_table "mobile_orders", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "current_state", default: "processing", null: false
    t.uuid "mobile_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["mobile_id"], name: "index_mobile_orders_on_mobile_id"
    t.index ["user_id"], name: "index_mobile_orders_on_user_id"
  end

  create_table "mobile_transitions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "metadata", default: "{}"
    t.uuid "mobile_id", null: false
    t.boolean "most_recent", default: true, null: false
    t.integer "sort_key", null: false
    t.string "to_state", null: false
    t.datetime "updated_at", null: false
    t.index ["mobile_id", "sort_key"], name: "index_mobile_transitions_on_mobile_id_and_sort_key", unique: true
    t.index ["mobile_id"], name: "index_mobile_transitions_on_mobile_id"
  end

  create_table "mobiles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "current_state", default: "for_sale", null: false
    t.string "description", null: false
    t.text "manual", null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
  end

  create_table "news", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
  end

# Could not dump table "notifications" because of following ArgumentError
#   wrong number of arguments (given 2, expected 1)


  create_table "order_summaries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "mobile_order_count", default: 0, null: false
    t.datetime "updated_at", null: false
  end

# Could not dump table "proxy_ports" because of following ArgumentError
#   wrong number of arguments (given 2, expected 1)


  create_table "request_summaries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "account_creations_count", default: 0, null: false
    t.integer "app_activations_count", default: 0, null: false
    t.integer "browser_activations_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.integer "license_activations_count", default: 0, null: false
    t.integer "topups_count", default: 0, null: false
    t.datetime "updated_at", null: false
  end

  create_table "resource_countries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "resource_types", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "country_id"
    t.datetime "created_at", null: false
    t.string "description"
    t.decimal "price", precision: 10, scale: 2, default: "99.0", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.string "wiki"
    t.index ["country_id"], name: "index_resource_types_on_country_id"
  end

  create_table "resources", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "current_state", default: "archiving", null: false
    t.uuid "owner_id"
    t.string "password"
    t.uuid "resource_type_id", null: false
    t.string "title", default: "DummyResource", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_id"], name: "index_resources_on_owner_id"
    t.index ["resource_type_id"], name: "index_resources_on_resource_type_id"
  end

  create_table "resources_transitions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "metadata", default: "{}"
    t.boolean "most_recent", default: true, null: false
    t.uuid "resource_id", null: false
    t.integer "sort_key", null: false
    t.string "to_state", null: false
    t.datetime "updated_at", null: false
    t.index ["resource_id", "sort_key"], name: "index_resources_transitions_on_resource_id_and_sort_key", unique: true
  end

  create_table "rules", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "topup_transitions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "metadata", default: "{}"
    t.boolean "most_recent", default: false, null: false
    t.integer "sort_key", null: false
    t.string "to_state", null: false
    t.uuid "topup_id", null: false
    t.datetime "updated_at", null: false
    t.index ["topup_id", "most_recent"], name: "index_topup_transitions_on_topup_id_and_most_recent", unique: true, where: "(most_recent = true)"
    t.index ["topup_id", "sort_key"], name: "index_topup_transitions_on_topup_id_and_sort_key", unique: true
  end

  create_table "topups", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.string "current_state", default: "pending", null: false
    t.datetime "processed_at"
    t.string "recipient_wallet_address", null: false
    t.string "sender_wallet_address", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["user_id"], name: "index_topups_on_user_id"
  end

  create_table "user_transitions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "metadata", default: "{}"
    t.boolean "most_recent", default: true, null: false
    t.integer "sort_key", null: false
    t.string "to_state", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["user_id", "sort_key"], name: "index_user_transitions_on_user_id_and_sort_key", unique: true
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "current_state", default: "incomplete", null: false
    t.string "password_digest", null: false
    t.string "personal_token"
    t.string "role", default: "user"
    t.decimal "total_spent", precision: 12, scale: 2, default: "0.0", null: false
    t.string "type"
    t.datetime "updated_at", null: false
    t.string "username", null: false
    t.index ["current_state"], name: "index_users_on_current_state"
    t.index ["personal_token"], name: "index_users_on_personal_token", unique: true
    t.index ["type"], name: "index_users_on_type"
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "wallets", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["address"], name: "index_wallets_on_address", unique: true
  end

  create_table "wiki_articles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.uuid "wiki_category_id", null: false
  end

  create_table "wiki_categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "account_licenses", "accounts"
  add_foreign_key "account_licenses", "licenses"
  add_foreign_key "account_licenses_transitions", "account_licenses"
  add_foreign_key "accounts", "users"
  add_foreign_key "accounts_transitions", "accounts"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "app_account_transitions", "app_accounts"
  add_foreign_key "app_accounts", "accounts"
  add_foreign_key "app_accounts", "app_demos"
  add_foreign_key "app_accounts", "app_purchases"
  add_foreign_key "app_demos", "apps"
  add_foreign_key "app_demos", "users"
  add_foreign_key "app_license_keys", "app_accounts"
  add_foreign_key "app_purchases", "apps"
  add_foreign_key "app_purchases", "users"
  add_foreign_key "apps", "app_countries", column: "country_id"
  add_foreign_key "balance_transitions", "balances"
  add_foreign_key "balances", "users"
  add_foreign_key "browser_account_transitions", "browser_accounts"
  add_foreign_key "browser_accounts", "accounts"
  add_foreign_key "browser_accounts", "browser_purchases"
  add_foreign_key "browser_purchases", "browsers"
  add_foreign_key "browser_purchases", "users"
  add_foreign_key "bug_report_transitions", "bug_reports"
  add_foreign_key "bug_reports", "users"
  add_foreign_key "holds_transitions", "holds"
  add_foreign_key "mobile_order_transitions", "mobile_orders"
  add_foreign_key "mobile_orders", "mobiles"
  add_foreign_key "mobile_orders", "users"
  add_foreign_key "mobile_transitions", "mobiles"
  add_foreign_key "notifications", "users"
  add_foreign_key "proxy_ports", "users"
  add_foreign_key "resource_types", "resource_countries", column: "country_id"
  add_foreign_key "resources", "resource_types"
  add_foreign_key "resources", "users", column: "owner_id"
  add_foreign_key "resources_transitions", "resources"
  add_foreign_key "topup_transitions", "topups"
  add_foreign_key "topups", "users"
  add_foreign_key "user_transitions", "users"
  add_foreign_key "wiki_articles", "wiki_categories"
end
