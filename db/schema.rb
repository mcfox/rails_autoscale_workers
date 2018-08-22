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

ActiveRecord::Schema.define(version: 2018_08_22_125542) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "applications", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "aws_access_key_id"
    t.string "aws_secret_access_key"
    t.boolean "valid_aws_credentials", default: false
    t.string "jobs_url"
    t.boolean "valid_jobs_url", default: false
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cycles", id: :serial, force: :cascade do |t|
    t.integer "work_manager_id"
    t.integer "queue_jobs", default: 0
    t.integer "new_jobs", default: 0
    t.integer "processed_jobs", default: 0
    t.integer "workers", default: 0
    t.integer "desired_workers", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "current_workers", default: 0
    t.index ["work_manager_id"], name: "index_cycles_on_work_manager_id"
  end

  create_table "intervals", id: :serial, force: :cascade do |t|
    t.integer "cycle_id"
    t.integer "position", default: 0
    t.integer "jobs", default: 0
    t.integer "slice_jobs", default: 0
    t.integer "workers", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cycle_id"], name: "index_intervals_on_cycle_id"
  end

  create_table "old_passwords", id: :serial, force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at", null: false
    t.string "encrypted_password", null: false
    t.string "password_archivable_type", null: false
    t.integer "password_archivable_id", null: false
    t.string "password_salt"
    t.index ["password_archivable_type", "password_archivable_id"], name: "index_password_archivable"
  end

  create_table "security_questions", id: :serial, force: :cascade do |t|
    t.string "locale", null: false
    t.string "name", null: false
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", default: "", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: ""
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.integer "invited_by_id"
    t.string "invited_by_type"
    t.integer "invitations_count", default: 0
    t.string "authentication_token"
    t.string "provider"
    t.string "uid"
    t.string "unique_session_id", limit: 20
    t.datetime "password_changed_at"
    t.datetime "last_activity_at"
    t.datetime "expired_at"
    t.string "paranoid_verification_code"
    t.integer "paranoid_verification_attempt", default: 0
    t.datetime "paranoid_verified_at"
    t.integer "security_question_id"
    t.string "security_question_answer"
    t.index ["expired_at"], name: "index_users_on_expired_at"
    t.index ["invitations_count"], name: "index_users_on_invitations_count"
    t.index ["invited_by_id", "invited_by_type"], name: "index_users_on_invited_by_id_and_invited_by_type"
    t.index ["last_activity_at"], name: "index_users_on_last_activity_at"
    t.index ["paranoid_verification_code"], name: "index_users_on_paranoid_verification_code"
    t.index ["paranoid_verified_at"], name: "index_users_on_paranoid_verified_at"
    t.index ["password_changed_at"], name: "index_users_on_password_changed_at"
  end

  create_table "work_managers", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "aws_region"
    t.string "autoscalinggroup_name"
    t.string "queue_name"
    t.integer "max_workers"
    t.integer "min_workers"
    t.integer "minutes_to_process"
    t.integer "jobs_per_cycle"
    t.integer "minutes_between_cycles"
    t.boolean "active", default: true
    t.datetime "last_check"
    t.string "last_error", limit: 500
    t.integer "application_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["application_id"], name: "index_work_managers_on_application_id"
  end

  add_foreign_key "cycles", "work_managers"
  add_foreign_key "intervals", "cycles"
  add_foreign_key "work_managers", "applications"
end
