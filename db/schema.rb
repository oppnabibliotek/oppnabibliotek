# -*- encoding : utf-8 -*-
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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110908101555) do

  create_table "agegroups", :force => true do |t|
    t.string   "name"
    t.integer  "targetgroup_id"
    t.integer  "from"
    t.integer  "to"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "assessments", :force => true do |t|
    t.integer  "grade"
    t.boolean  "published"
    t.integer  "user_id"
    t.integer  "book_id"
    t.integer  "edition_id"
    t.text     "comment_header"
    t.text     "comment_text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "blacklistings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "assessment_id"
    t.integer  "library_id"
    t.boolean  "global"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "description_id"
  end

  create_table "books", :force => true do |t|
    t.string   "title"
    t.string   "authorfirstname"
    t.string   "authorlastname"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "signum_id"
    t.integer  "temp_bookid"
    t.string   "temp_signumtext", :limit => 100
    t.integer  "targetgroup_id"
    t.integer  "agegroup_id"
    t.string   "booktitle_part1"
    t.string   "booktitle_part2"
    t.string   "group_inst"
    t.boolean  "reserved"
  end

  create_table "books_keywords", :id => false, :force => true do |t|
    t.integer "book_id"
    t.integer "keyword_id"
  end

  create_table "books_sb_keywords", :id => false, :force => true do |t|
    t.integer "book_id"
    t.integer "sb_keyword_id"
  end

  create_table "counties", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "temp_countyid"
  end

  create_table "departments", :force => true do |t|
    t.string  "name"
    t.string  "ssbid"
    t.integer "library_id"
  end

  create_table "departments_users", :id => false, :force => true do |t|
    t.integer "department_id"
    t.integer "user_id"
  end

  create_table "descriptions", :force => true do |t|
    t.text     "text"
    t.integer  "edition_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "source_id"
  end

  create_table "editions", :force => true do |t|
    t.string   "isbn"
    t.string   "illustrator"
    t.integer  "year"
    t.integer  "book_id"
    t.integer  "temp_bookid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "translator"
    t.integer  "recordnr"
    t.string   "recordcompany"
    t.string   "auxcreator"
    t.string   "mediatype"
    t.string   "mediatypecode"
    t.string   "ssb_key"
    t.string   "imageurl"
    t.boolean  "published"
    t.boolean  "manual"
    t.integer  "libris_id"
  end

  create_table "images", :force => true do |t|
    t.integer  "edition_id"
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
    t.string   "content_type"
    t.string   "filename"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "temp_imageid"
  end

  create_table "keywords", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "libraries", :force => true do |t|
    t.string   "name"
    t.integer  "county_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "userinfolink"
    t.text     "infolink"
    t.text     "bookinfolink"
    t.integer  "temp_libaryid"
    t.text     "searchstring_encoding"
    t.text     "stylesheet"
    t.boolean  "keep_isbn_dashes"
    t.string   "abuse_email"
    t.string   "dev_key"
  end

  create_table "reports", :force => true do |t|
    t.integer  "user_id"
    t.string   "subject"
    t.string   "message"
    t.integer  "tag_id"
    t.integer  "assessment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "description_id"
  end

  create_table "rights", :force => true do |t|
    t.string "name"
    t.string "controller"
    t.string "action"
  end

  create_table "rights_roles", :id => false, :force => true do |t|
    t.integer "right_id"
    t.integer "role_id"
  end

  create_table "roles", :force => true do |t|
    t.string "name"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  create_table "sb_keywords", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "namecode"
  end

  create_table "signums", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id",     :null => false
    t.integer  "user_id",    :null => false
    t.integer  "book_id",    :null => false
    t.integer  "edition_id"
    t.boolean  "published"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tags", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "targetgroups", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string  "username"
    t.string  "password_hash"
    t.string  "firstname"
    t.string  "lastname"
    t.string  "email"
    t.integer "library_id"
    t.integer "temp_userid"
    t.string  "dynamicinfolink"
    t.string  "alias"
    t.string  "foreign_id"
  end

end
