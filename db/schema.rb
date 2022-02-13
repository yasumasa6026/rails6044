# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_01_24_104007) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "alloctbls", id: :decimal, precision: 38, force: :cascade do |t|
    t.string "srctblname", limit: 30
    t.decimal "srctblid", precision: 38
    t.string "contents", limit: 4000
    t.string "remark", limit: 4000
    t.decimal "persons_id_upd", precision: 38, null: false
    t.datetime "updated_at", precision: 6
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.decimal "trngantts_id", precision: 38
    t.decimal "qty", precision: 22, scale: 6
    t.decimal "qty_stk", precision: 22, scale: 6
    t.decimal "qty_linkto_alloctbl", precision: 22
    t.decimal "qty_sch", precision: 22, scale: 6
    t.string "allocfree", limit: 5
    t.index ["trngantts_id", "srctblname", "srctblid"], name: "alloctbls_uky10", unique: true
  end

  create_table "asstwhs", id: :decimal, precision: 38, force: :cascade do |t|
    t.decimal "locas_id_asstwh", precision: 38, null: false
    t.decimal "chrgs_id_asstwh", precision: 38, null: false
    t.string "acceptance_proc", limit: 1
    t.string "stktaking_proc", limit: 1
    t.string "autocreate_inst", limit: 1
    t.string "contents", limit: 4000
    t.date "expiredate"
    t.string "remark", limit: 4000
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.decimal "persons_id_upd", precision: 38, null: false
  end

  create_table "billacts", id: :decimal, precision: 38, force: :cascade do |t|
    t.datetime "isudate", precision: 6
    t.datetime "saledate", precision: 6
    t.datetime "paymentdate", precision: 6
    t.decimal "qty", precision: 22, scale: 6
    t.decimal "price", precision: 38, scale: 4
    t.decimal "tax", precision: 38, scale: 4
    t.string "sno", limit: 40
    t.string "tblname", limit: 30
    t.decimal "tblid", precision: 38
    t.string "orgtblname", limit: 30
    t.decimal "orgtblid", precision: 38
    t.date "expiredate"
    t.string "contents", limit: 4000
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "remark", limit: 4000
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.decimal "itms_id", precision: 38, null: false
    t.decimal "bills_id", precision: 38, null: false
    t.decimal "cash", precision: 22, scale: 2
  end

  create_table "billinsts", id: :decimal, precision: 38, force: :cascade do |t|
    t.datetime "isudate", precision: 6
    t.datetime "saledate", precision: 6
    t.datetime "duedate", precision: 6
    t.decimal "qty", precision: 22, scale: 6
    t.decimal "price", precision: 38, scale: 4
    t.decimal "amt", precision: 18, scale: 4
    t.decimal "tax", precision: 38, scale: 4
    t.string "sno", limit: 40
    t.string "tblname", limit: 30
    t.decimal "tblid", precision: 38
    t.string "orgtblname", limit: 30
    t.decimal "orgtblid", precision: 38
    t.date "expiredate"
    t.string "contents", limit: 4000
    t.decimal "persons_id_upd", precision: 38, null: false
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.string "update_ip", limit: 40
    t.string "remark", limit: 4000
    t.decimal "itms_id", precision: 38, null: false
    t.decimal "bills_id", precision: 38, null: false
  end

  create_table "billords", id: :decimal, precision: 38, force: :cascade do |t|
    t.datetime "isudate", precision: 6
    t.datetime "saledate", precision: 6
    t.datetime "duedate", precision: 6
    t.decimal "locas_id_to", precision: 38, null: false
    t.decimal "qty", precision: 22, scale: 6
    t.decimal "price", precision: 38, scale: 4
    t.decimal "amt", precision: 18, scale: 4
    t.decimal "tax", precision: 38, scale: 4
    t.string "sno", limit: 40
    t.string "tblname", limit: 30
    t.decimal "tblid", precision: 38
    t.decimal "orgtblid", precision: 38
    t.date "expiredate"
    t.string "contents", limit: 4000
    t.decimal "persons_id_upd", precision: 38, null: false
    t.datetime "created_at", precision: 6
    t.string "update_ip", limit: 40
    t.datetime "updated_at", precision: 6
    t.string "remark", limit: 4000
    t.decimal "itms_id", precision: 38, null: false
    t.decimal "bills_id", precision: 38, null: false
    t.decimal "crrs_id_billord", precision: 22, default: "0", null: false
    t.string "gno_billsch", limit: 40
  end

  create_table "bills", id: :decimal, precision: 38, force: :cascade do |t|
    t.string "contents", limit: 4000
    t.string "personname", limit: 30
    t.decimal "locas_id_bill", precision: 38, null: false
    t.date "expiredate"
    t.string "remark", limit: 4000
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.decimal "chrgs_id_bill", precision: 22
    t.decimal "crrs_id_bill", precision: 22
  end

  create_table "billschs", id: :decimal, precision: 38, force: :cascade do |t|
    t.datetime "isudate", precision: 6
    t.datetime "saledate", precision: 6
    t.datetime "duedate", precision: 6
    t.decimal "price", precision: 38, scale: 4
    t.decimal "tax", precision: 38, scale: 4
    t.string "sno", limit: 40
    t.date "expiredate"
    t.string "contents", limit: 4000
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "remark", limit: 4000
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.string "update_ip", limit: 40
    t.decimal "itms_id", precision: 38, null: false
    t.decimal "bills_id", precision: 38, null: false
    t.decimal "qty_sch", precision: 22, scale: 6
    t.decimal "amt_sch", precision: 38, scale: 4
    t.decimal "processseq", precision: 38
    t.string "gno", limit: 40
  end

  create_table "blktbs", id: :decimal, precision: 38, force: :cascade do |t|
    t.decimal "pobjects_id_tbl", precision: 38
    t.string "remark", limit: 4000
    t.decimal "persons_id_upd", precision: 38
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.date "expiredate"
    t.datetime "updated_at", precision: 6
    t.string "seltbls", limit: 4000
    t.string "contents", limit: 4000
    t.index ["pobjects_id_tbl"], name: "blktbs_ukys1", unique: true
  end

  create_table "blkukys", id: :decimal, precision: 38, force: :cascade do |t|
    t.string "contents", limit: 4000
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.decimal "persons_id_upd", precision: 38
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.decimal "seqno", precision: 38
    t.decimal "tblfields_id", precision: 38
    t.string "grp", limit: 10
    t.index ["grp", "tblfields_id"], name: "blkukys_ukys1", unique: true
  end

  create_table "boxes", id: :decimal, precision: 38, force: :cascade do |t|
    t.decimal "persons_id_upd", precision: 38
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.string "update_ip", limit: 40
    t.string "boxtype", limit: 20
    t.string "contents", limit: 4000
    t.decimal "depth", precision: 7, scale: 2
    t.date "expiredate"
    t.decimal "height", precision: 22, scale: 2
    t.decimal "outdepth", precision: 7, scale: 2
    t.decimal "outheight", precision: 7, scale: 2
    t.decimal "outwide", precision: 7, scale: 2
    t.string "remark", limit: 4000
    t.decimal "units_id_box", precision: 38
    t.decimal "units_id_outbox", precision: 38
    t.decimal "wide", precision: 7, scale: 2
    t.string "code", limit: 50
    t.string "name", limit: 100
    t.index ["code"], name: "boxes_ukys10", unique: true
  end

  create_table "buttons", id: :decimal, precision: 38, force: :cascade do |t|
    t.date "expiredate"
    t.string "contents", limit: 4000
    t.string "remark", limit: 4000
    t.decimal "persons_id_upd", precision: 38
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.decimal "seqno", precision: 38
    t.string "caption", limit: 20
    t.string "title", limit: 30
    t.string "buttonicon", limit: 40
    t.string "onclickbutton", limit: 4000
    t.string "getgridparam", limit: 10
    t.string "editgridrow", limit: 4000
    t.string "aftershowform", limit: 4000
    t.string "code", limit: 50
  end

  create_table "chilscreens", id: :decimal, precision: 38, force: :cascade do |t|
    t.date "expiredate"
    t.string "contents", limit: 4000
    t.string "remark", limit: 4000
    t.decimal "persons_id_upd", precision: 38
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.decimal "screenfields_id", precision: 38
    t.decimal "screenfields_id_ch", precision: 38
    t.string "grp", limit: 10
  end

  create_table "chrgs", id: :decimal, precision: 38, force: :cascade do |t|
    t.string "contents", limit: 4000
    t.datetime "created_at", precision: 6
    t.date "expiredate"
    t.decimal "persons_id_chrg", precision: 38
    t.decimal "persons_id_upd", precision: 38
    t.string "remark", limit: 4000
    t.string "update_ip", limit: 40
    t.datetime "updated_at", precision: 6
  end

  create_table "classlists", id: :decimal, precision: 38, force: :cascade do |t|
    t.string "code", limit: 50, null: false
    t.string "name", limit: 100, null: false
    t.string "contents", limit: 4000
    t.date "expiredate"
    t.string "remark", limit: 4000
    t.decimal "persons_id_upd", precision: 38, null: false
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.string "update_ip", limit: 40
    t.index ["code"], name: "classlists_uky1", unique: true
  end

  create_table "conacts", id: :decimal, precision: 38, force: :cascade do |t|
    t.decimal "shelfnos_id_fm", precision: 22, null: false
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.decimal "persons_id_upd", precision: 38, null: false
    t.decimal "itms_id", precision: 38, null: false
    t.datetime "duedate", precision: 6
    t.datetime "isudate", precision: 6
    t.string "contents", limit: 4000
    t.decimal "processseq", precision: 38
    t.string "manual", limit: 1
    t.decimal "qty_stk", precision: 22, scale: 6
    t.string "paretblname", limit: 30
    t.decimal "paretblid", precision: 38
    t.string "lotno", limit: 50
    t.string "packno", limit: 10
  end

  create_table "coninsts", id: :decimal, precision: 38, force: :cascade do |t|
    t.decimal "shelfnos_id_fm", precision: 22, null: false
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.decimal "persons_id_upd", precision: 38, null: false
    t.decimal "itms_id", precision: 38, null: false
    t.decimal "qty", precision: 22, scale: 6
    t.datetime "duedate", precision: 6
    t.datetime "toduedate", precision: 6
    t.datetime "isudate", precision: 6
    t.string "contents", limit: 4000
    t.datetime "starttime", precision: 6
    t.decimal "processseq", precision: 38
    t.string "manual", limit: 1
    t.string "paretblname", limit: 30
    t.decimal "paretblid", precision: 38
  end

  create_table "conords", id: :decimal, precision: 38, force: :cascade do |t|
    t.decimal "shelfnos_id_fm", precision: 22, null: false
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.decimal "persons_id_upd", precision: 38, null: false
    t.decimal "itms_id", precision: 38, null: false
    t.decimal "qty", precision: 22, scale: 6
    t.datetime "duedate", precision: 6
    t.datetime "isudate", precision: 6
    t.string "contents", limit: 4000
    t.decimal "processseq", precision: 38
    t.string "manual", limit: 1
    t.string "paretblname", limit: 30
    t.decimal "paretblid", precision: 38
    t.string "lotno", limit: 50
    t.string "packno", limit: 10
  end

  create_table "conschs", id: :decimal, precision: 38, force: :cascade do |t|
    t.decimal "shelfnos_id_fm", precision: 22, null: false
    t.decimal "qty_sch", precision: 22, scale: 6
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.decimal "persons_id_upd", precision: 38, null: false
    t.decimal "itms_id", precision: 38, null: false
    t.datetime "duedate", precision: 6
    t.datetime "isudate", precision: 6
    t.string "contents", limit: 4000
    t.decimal "processseq", precision: 38
    t.string "manual", limit: 1
    t.string "paretblname", limit: 30
    t.decimal "paretblid", precision: 38
    t.string "lotno", limit: 50
    t.string "packno", limit: 10
  end

  create_table "crrs", id: :decimal, precision: 38, force: :cascade do |t|
    t.string "contents", limit: 4000
    t.decimal "amtdecimal", precision: 38
    t.string "code", limit: 50
    t.datetime "created_at", precision: 6
    t.date "expiredate"
    t.string "name", limit: 100
    t.decimal "persons_id_upd", precision: 38
    t.decimal "pricedecimal", precision: 38
    t.string "remark", limit: 100
    t.string "update_ip", limit: 40
    t.datetime "updated_at", precision: 6
    t.index ["code", "expiredate"], name: "crrs_uky1", unique: true
  end

  create_table "custacts", id: :decimal, precision: 38, force: :cascade do |t|
    t.string "sno", limit: 40
    t.datetime "isudate", precision: 6
    t.string "itm_code_client", limit: 50
    t.datetime "saledate", precision: 6
    t.decimal "qty", precision: 22, scale: 6
    t.decimal "price", precision: 38, scale: 4
    t.decimal "amt", precision: 18, scale: 4
    t.string "contract_price", limit: 1
    t.date "expiredate"
    t.string "remark", limit: 4000
    t.decimal "custs_id", precision: 38, null: false
    t.decimal "custrcvplcs_id", precision: 38, null: false
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.decimal "shelfnos_id_fm", precision: 22, null: false
    t.decimal "opeitms_id", precision: 38, default: "0", null: false
    t.decimal "chrgs_id_custord", precision: 38, default: "0", null: false
    t.string "sno_custord", limit: 50
    t.string "sno_custinst", limit: 50
    t.string "cno_custord", limit: 50
    t.string "cno_custinst", limit: 50
    t.string "sno_custdlv", limit: 50
    t.string "cno_custdlv", limit: 50
    t.string "invoiceno", limit: 50
    t.string "cartonno", limit: 50
  end

  create_table "custdlvs", id: :decimal, precision: 38, force: :cascade do |t|
    t.string "sno", limit: 40
    t.datetime "isudate", precision: 6
    t.string "itm_code_client", limit: 50
    t.decimal "price", precision: 38, scale: 4
    t.decimal "amt", precision: 18, scale: 4
    t.datetime "starttime", precision: 6
    t.string "contract_price", limit: 1
    t.string "cno", limit: 40
    t.string "gno", limit: 40
    t.date "expiredate"
    t.string "remark", limit: 4000
    t.decimal "custs_id", precision: 38, null: false
    t.decimal "custrcvplcs_id", precision: 38, null: false
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.decimal "shelfnos_id_fm", precision: 22, null: false
    t.decimal "opeitms_id", precision: 38, default: "0", null: false
    t.string "sno_custord", limit: 50
    t.string "sno_custinst", limit: 50
    t.string "cno_custord", limit: 50
    t.string "cno_custinst", limit: 50
    t.datetime "depdate", precision: 6
    t.string "cartonno", limit: 50
    t.decimal "qty_stk", precision: 22, scale: 6
    t.decimal "qty_case", precision: 22
    t.decimal "chrgs_id_custord", precision: 38, default: "0", null: false
    t.string "invoiceno", limit: 50
  end

  create_table "custinsts", id: :decimal, precision: 38, force: :cascade do |t|
    t.string "sno", limit: 40
    t.datetime "isudate", precision: 6
    t.datetime "duedate", precision: 6
    t.string "itm_code_client", limit: 50
    t.decimal "qty", precision: 22, scale: 6
    t.decimal "price", precision: 38, scale: 4
    t.decimal "amt", precision: 18, scale: 4
    t.datetime "starttime", precision: 6
    t.string "contract_price", limit: 1
    t.string "cno", limit: 40
    t.string "gno", limit: 40
    t.date "expiredate"
    t.string "remark", limit: 4000
    t.decimal "custs_id", precision: 38, null: false
    t.decimal "custrcvplcs_id", precision: 38, null: false
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.decimal "shelfnos_id_fm", precision: 22, null: false
    t.decimal "opeitms_id", precision: 38, default: "0", null: false
    t.decimal "chrgs_id_custord", precision: 38, default: "0", null: false
    t.string "sno_custord", limit: 50
    t.string "cno_custord", limit: 50
  end

  create_table "custords", id: :decimal, precision: 38, force: :cascade do |t|
    t.string "itm_code_client", limit: 50
    t.datetime "duedate", precision: 6
    t.datetime "toduedate", precision: 6
    t.datetime "isudate", precision: 6
    t.decimal "qty", precision: 22, scale: 6
    t.decimal "price", precision: 38, scale: 4
    t.string "contract_price", limit: 1
    t.decimal "amt", precision: 18, scale: 4
    t.string "sno", limit: 40
    t.string "cno", limit: 40
    t.string "gno", limit: 40
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.string "contents", limit: 4000
    t.decimal "custs_id", precision: 38, null: false
    t.decimal "opeitms_id", precision: 38, null: false
    t.decimal "prjnos_id", precision: 38, null: false
    t.decimal "custrcvplcs_id", precision: 38
    t.datetime "starttime", precision: 6
    t.decimal "shelfnos_id_fm", precision: 22, null: false
    t.decimal "chrgs_id_custord", precision: 38, default: "0", null: false
    t.decimal "crrs_id_custord", precision: 22, default: "0", null: false
    t.string "sno_custsch", limit: 50
  end

  create_table "custrcvplcs", id: :decimal, precision: 38, force: :cascade do |t|
    t.string "contents", limit: 4000
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.string "stktaking_proc", limit: 1
    t.decimal "locas_id_custrcvplc", precision: 38, null: false
  end

  create_table "custrets", id: :decimal, precision: 38, force: :cascade do |t|
    t.string "cno_custact", limit: 50
    t.string "sno_custact", limit: 50
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.decimal "persons_id_upd", precision: 38, null: false
    t.decimal "qty", precision: 22, scale: 6
    t.decimal "price", precision: 38, scale: 4
    t.decimal "amt", precision: 18, scale: 4
    t.string "sno", limit: 40
    t.datetime "isudate", precision: 6
    t.decimal "custs_id", precision: 38, null: false
    t.decimal "opeitms_id", precision: 38, null: false
    t.string "contract_price", limit: 1
    t.decimal "custrcvplcs_id", precision: 38, null: false
    t.decimal "chrgs_id_custord", precision: 38, null: false
    t.date "retdate"
    t.string "itm_code_client", limit: 50
    t.decimal "shelfnos_id_to", precision: 38, null: false
  end

  create_table "custs", id: :decimal, precision: 38, force: :cascade do |t|
    t.string "custtype", limit: 1
    t.decimal "locas_id_cust", precision: 38, null: false
    t.decimal "chrgs_id_cust", precision: 38, null: false
    t.string "contract_price", limit: 1
    t.string "rule_price", limit: 1
    t.string "amtround", limit: 2
    t.decimal "amtdecimal", precision: 38
    t.string "autocreate_custact", limit: 1
    t.string "contents", limit: 4000
    t.date "expiredate"
    t.string "remark", limit: 4000
    t.decimal "bills_id", precision: 38, null: false
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.datetime "updated_at", precision: 6
    t.datetime "created_at", precision: 6
    t.string "personname", limit: 30
    t.decimal "crrs_id_cust", precision: 38, default: "0", null: false
    t.index ["locas_id_cust"], name: "custs_uky10", unique: true
  end

  create_table "custschs", id: :decimal, precision: 38, force: :cascade do |t|
    t.string "contents", limit: 4000
    t.datetime "duedate", precision: 6
    t.datetime "isudate", precision: 6
    t.decimal "price", precision: 38, scale: 4
    t.string "contract_price", limit: 1
    t.string "sno", limit: 40
    t.string "cno", limit: 40
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.decimal "prjnos_id", precision: 38, null: false
    t.decimal "custs_id", precision: 38, null: false
    t.decimal "opeitms_id", precision: 38, null: false
    t.datetime "starttime", precision: 6
    t.decimal "qty_sch", precision: 22, scale: 6
    t.decimal "shelfnos_id_fm", precision: 22, null: false
    t.decimal "amt_sch", precision: 38, scale: 4
    t.string "gno", limit: 40
    t.decimal "custrcvplcs_id", precision: 38, default: "0", null: false
    t.index ["custs_id", "cno"], name: "custschs_uky20", unique: true
    t.index ["opeitms_id"], name: "aaa"
    t.index ["sno"], name: "custschs_uky10", unique: true
  end

  create_table "custwhs", id: :decimal, precision: 38, force: :cascade do |t|
    t.decimal "custrcvplcs_id", precision: 38, null: false
    t.datetime "duedate", precision: 6
    t.decimal "qty_stk", precision: 22, scale: 6
    t.decimal "qty", precision: 22, scale: 6
    t.decimal "qty_sch", precision: 22, scale: 6
    t.string "lotno", limit: 50
    t.date "expiredate"
    t.string "remark", limit: 4000
    t.decimal "persons_id_upd", precision: 38, null: false
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.string "update_ip", limit: 40
    t.decimal "itms_id", precision: 38, default: "0", null: false
    t.decimal "processseq", precision: 38
  end

  create_table "dlvacts", id: :decimal, precision: 38, force: :cascade do |t|
    t.datetime "isudate", precision: 6
    t.datetime "depdate", precision: 6
    t.decimal "locas_id_to", precision: 38, null: false
    t.decimal "qty", precision: 22, scale: 6
    t.decimal "qty_case", precision: 22
    t.string "sno", limit: 40
    t.string "orgtblname", limit: 30
    t.decimal "orgtblid", precision: 38
    t.date "expiredate"
    t.string "contents", limit: 4000
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "remark", limit: 4000
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.decimal "custrcvplcs_id", precision: 38, null: false
    t.decimal "transports_id", precision: 38, null: false
    t.decimal "asstwhs_id", precision: 38, null: false
    t.decimal "itms_id", precision: 38, null: false
    t.decimal "prjnos_id", precision: 38, null: false
  end

  create_table "dlvinsts", id: :decimal, precision: 38, force: :cascade do |t|
    t.datetime "isudate", precision: 6
    t.datetime "duedate", precision: 6
    t.datetime "depdate", precision: 6
    t.datetime "toduedate", precision: 6
    t.decimal "locas_id_to", precision: 38, null: false
    t.decimal "qty", precision: 22, scale: 6
    t.decimal "qty_case", precision: 22
    t.string "gno", limit: 40
    t.string "cno", limit: 40
    t.string "sno", limit: 40
    t.string "orgtblname", limit: 30
    t.decimal "orgtblid", precision: 38
    t.date "expiredate"
    t.string "contents", limit: 4000
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.string "remark", limit: 4000
    t.decimal "prjnos_id", precision: 38, null: false
    t.decimal "custrcvplcs_id", precision: 38, null: false
    t.decimal "itms_id", precision: 38, null: false
    t.decimal "asstwhs_id", precision: 38, null: false
    t.decimal "transports_id", precision: 38, null: false
  end

  create_table "dlvords", id: :decimal, precision: 38, force: :cascade do |t|
    t.string "confirm", limit: 1
    t.datetime "isudate", precision: 6
    t.datetime "duedate", precision: 6
    t.datetime "depdate", precision: 6
    t.datetime "toduedate", precision: 6
    t.decimal "locas_id_fm", precision: 38, null: false
    t.decimal "locas_id_to", precision: 38, null: false
    t.string "gno", limit: 40
    t.decimal "qty", precision: 22, scale: 6
    t.decimal "qty_case", precision: 22
    t.string "sno", limit: 40
    t.date "expiredate"
    t.string "contents", limit: 4000
    t.decimal "persons_id_upd", precision: 38, null: false
    t.datetime "updated_at", precision: 6
    t.datetime "created_at", precision: 6
    t.string "remark", limit: 4000
    t.string "update_ip", limit: 40
    t.decimal "custs_id", precision: 38, null: false
    t.decimal "itms_id", precision: 38, null: false
    t.decimal "prjnos_id", precision: 38, null: false
    t.decimal "transports_id", precision: 38, null: false
  end

  create_table "dlvschs", id: :decimal, precision: 38, force: :cascade do |t|
    t.datetime "isudate", precision: 6
    t.datetime "duedate", precision: 6
    t.datetime "depdate", precision: 6
    t.datetime "toduedate", precision: 6
    t.decimal "locas_id_fm", precision: 38, null: false
    t.decimal "locas_id_to", precision: 38, null: false
    t.decimal "price", precision: 38, scale: 4
    t.decimal "amt", precision: 18, scale: 4
    t.string "sno", limit: 40
    t.string "tblname", limit: 30
    t.decimal "tblid", precision: 38
    t.date "expiredate"
    t.string "contents", limit: 4000
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "remark", limit: 4000
    t.datetime "updated_at", precision: 6
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.decimal "prjnos_id", precision: 38, null: false
    t.decimal "itms_id", precision: 38, null: false
    t.decimal "transports_id", precision: 38, null: false
    t.decimal "qty_sch", precision: 22, scale: 6
  end

  create_table "dymschs", id: :decimal, precision: 38, force: :cascade do |t|
    t.string "contents", limit: 4000
    t.decimal "locas_id_to", precision: 38, null: false
    t.decimal "processseq_pare", precision: 38
    t.datetime "isudate", precision: 6
    t.datetime "starttime", precision: 6
    t.datetime "duedate", precision: 6
    t.datetime "toduedate", precision: 6
    t.decimal "qty_sch", precision: 22, scale: 6
    t.decimal "qty_case", precision: 22
    t.decimal "price", precision: 38, scale: 4
    t.decimal "amt", precision: 18, scale: 4
    t.string "contract_price", limit: 1
    t.decimal "tax", precision: 38, scale: 4
    t.string "sno", limit: 40
    t.string "tblname", limit: 30
    t.decimal "tblid", precision: 38
    t.date "expiredate"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "remark", limit: 4000
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.decimal "prjnos_id", precision: 38, null: false
    t.decimal "itms_id", precision: 38, null: false
    t.decimal "locas_id", precision: 38, null: false
  end

  create_table "fieldcodes", id: :decimal, precision: 38, force: :cascade do |t|
    t.decimal "pobjects_id_fld", precision: 38
    t.string "ftype", limit: 15
    t.decimal "fieldlength", precision: 38
    t.decimal "datascale", precision: 38
    t.string "remark", limit: 4000
    t.decimal "persons_id_upd", precision: 38
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.date "expiredate"
    t.datetime "updated_at", precision: 6
    t.decimal "dataprecision", precision: 38
    t.decimal "seqno", precision: 38
    t.string "contents", limit: 4000
    t.index ["pobjects_id_fld", "id"], name: "fieldcodes_pobjects_id_fld", unique: true
    t.index ["pobjects_id_fld"], name: "fieldcodes_uky10", unique: true
  end

  create_table "inamts", id: :decimal, precision: 38, force: :cascade do |t|
    t.datetime "starttime", precision: 6
    t.decimal "amt", precision: 18, scale: 4
    t.decimal "crrs_id", precision: 22, null: false
    t.date "expiredate"
    t.string "remark", limit: 4000
    t.decimal "persons_id_upd", precision: 38, null: false
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.string "update_ip", limit: 40
    t.decimal "locas_id_in", precision: 22
    t.decimal "alloctbls_id", precision: 38
    t.string "inoutflg", limit: 20
  end

  create_table "incustwhs", id: :decimal, precision: 38, force: :cascade do |t|
    t.decimal "custrcvplcs_id", precision: 38, null: false
    t.datetime "duedate", precision: 6
    t.decimal "qty_stk", precision: 22, scale: 6
    t.decimal "qty", precision: 22, scale: 6
    t.string "lotno", limit: 50
    t.string "packno", limit: 10
    t.date "expiredate"
    t.string "remark", limit: 4000
    t.decimal "persons_id_upd", precision: 38, null: false
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.string "update_ip", limit: 40
    t.decimal "alloctbls_id", precision: 38
    t.decimal "qty_sch", precision: 22, scale: 6
    t.string "inoutflg", limit: 20
  end

  create_table "inoutlotstks", id: :decimal, precision: 38, force: :cascade do |t|
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "contents", limit: 4000
    t.string "srctblname", limit: 30
    t.decimal "srctblid", precision: 38
    t.decimal "qty_sch", precision: 22, scale: 6
    t.decimal "qty", precision: 22, scale: 6
    t.decimal "qty_stk", precision: 22, scale: 6
    t.decimal "trngantts_id", precision: 38, default: "0", null: false
    t.string "tblname", limit: 30
    t.decimal "tblid", precision: 38
  end

  create_table "inspacts", id: :decimal, precision: 38, force: :cascade do |t|
    t.string "sno", limit: 40
    t.datetime "isudate", precision: 6
    t.datetime "rcptdate", precision: 6
    t.decimal "qty", precision: 18, scale: 4
    t.decimal "price", precision: 38, scale: 4
    t.decimal "amt", precision: 18, scale: 4
    t.decimal "tax", precision: 38, scale: 4
    t.string "contract_price", limit: 1
    t.string "cno", limit: 40
    t.string "gno", limit: 40
    t.string "itm_code_client", limit: 50
    t.string "lotno", limit: 50
    t.string "packno", limit: 10
    t.string "contents", limit: 4000
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.decimal "suppliers_id", precision: 22, null: false
    t.decimal "locas_id_to", precision: 38, null: false
    t.decimal "shelfnos_id_act", precision: 38, null: false
    t.decimal "opeitms_id", precision: 38, null: false
    t.decimal "prjnos_id", precision: 38, null: false
    t.decimal "chrgs_id", precision: 38, null: false
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.string "sno_purord", limit: 50
    t.string "sno_inspord", limit: 50
    t.decimal "qty_fail", precision: 22, scale: 5
    t.decimal "reasons_id", precision: 22
  end

  create_table "inspinsts", id: :decimal, precision: 38, force: :cascade do |t|
    t.string "sno", limit: 40
    t.string "cno", limit: 40
    t.datetime "isudate", precision: 6
    t.datetime "duedate", precision: 6
    t.decimal "qty", precision: 22, scale: 6
    t.decimal "price", precision: 38, scale: 4
    t.decimal "amt", precision: 18, scale: 4
    t.decimal "tax", precision: 38, scale: 4
    t.string "contract_price", limit: 1
    t.string "gno", limit: 40
    t.string "itm_code_client", limit: 50
    t.string "contents", limit: 4000
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.decimal "suppliers_id", precision: 22, null: false
    t.decimal "locas_id_to", precision: 38, null: false
    t.decimal "prjnos_id", precision: 38, null: false
    t.decimal "opeitms_id", precision: 38, null: false
    t.decimal "chrgs_id", precision: 38, null: false
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.string "sno_puract", limit: 50
    t.decimal "reasons_id", precision: 22
    t.decimal "shelfnos_id_to", precision: 38, null: false
  end

  create_table "inspords", id: :decimal, precision: 38, force: :cascade do |t|
    t.string "sno", limit: 40
    t.datetime "isudate", precision: 6
    t.datetime "duedate", precision: 6
    t.decimal "qty", precision: 22, scale: 6
    t.decimal "price", precision: 38, scale: 4
    t.decimal "amt", precision: 18, scale: 4
    t.decimal "tax", precision: 38, scale: 4
    t.string "contract_price", limit: 1
    t.string "gno", limit: 40
    t.string "itm_code_client", limit: 50
    t.string "contents", limit: 4000
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.decimal "suppliers_id", precision: 22, null: false
    t.decimal "prjnos_id", precision: 38, null: false
    t.decimal "chrgs_id", precision: 38, null: false
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.string "sno_purord", limit: 50
    t.decimal "reasons_id", precision: 22
    t.decimal "itms_id", precision: 38
    t.decimal "processseq", precision: 38
    t.decimal "shelfnos_id_to", precision: 38
    t.decimal "shelfnos_id_fm", precision: 22
  end

  create_table "inspschs", id: :decimal, precision: 38, force: :cascade do |t|
    t.string "sno", limit: 40
    t.datetime "isudate", precision: 6
    t.datetime "duedate", precision: 6
    t.decimal "qty", precision: 22, scale: 6
    t.decimal "qty_fail", precision: 22, scale: 5
    t.decimal "price", precision: 38, scale: 4
    t.decimal "amt", precision: 18, scale: 4
    t.decimal "tax", precision: 38, scale: 4
    t.string "contract_price", limit: 1
    t.string "gno", limit: 40
    t.string "itm_code_client", limit: 50
    t.string "contents", limit: 4000
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.decimal "opeitms_id", precision: 38, null: false
    t.decimal "suppliers_id", precision: 22, null: false
    t.decimal "locas_id_to", precision: 38, null: false
    t.decimal "prjnos_id", precision: 38, null: false
    t.decimal "chrgs_id", precision: 38, null: false
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
  end

  create_table "instks", id: :decimal, precision: 38, force: :cascade do |t|
    t.datetime "starttime", precision: 6
    t.string "lotno", limit: 50
    t.string "packno", limit: 10
    t.date "expiredate"
    t.string "remark", limit: 4000
    t.decimal "persons_id_upd", precision: 38, null: false
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.string "update_ip", limit: 40
    t.decimal "shelfnos_id_in", precision: 38
    t.string "inoutflg", limit: 20
    t.string "tblname", limit: 30
    t.decimal "tblid", precision: 38
  end

  create_table "itms", id: :decimal, precision: 38, force: :cascade do |t|
    t.string "code", limit: 50
    t.string "name", limit: 100
    t.decimal "units_id", precision: 38
    t.string "std", limit: 50
    t.string "model", limit: 50
    t.string "material", limit: 50
    t.string "design", limit: 50
    t.decimal "weight", precision: 7, scale: 2
    t.decimal "length", precision: 38, scale: 6
    t.decimal "wide", precision: 7, scale: 2
    t.decimal "deth", precision: 38, scale: 6
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.decimal "persons_id_upd", precision: 38
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.decimal "datascale", precision: 38
    t.decimal "classlists_id", precision: 38
    t.decimal "metcounter", precision: 5
    t.string "consumtype", limit: 3
    t.index ["code"], name: "itms_ukys1", unique: true
  end

  create_table "linktbls", id: :decimal, precision: 38, force: :cascade do |t|
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "sno", limit: 40
    t.string "contents", limit: 4000
    t.string "tblname", limit: 30
    t.decimal "tblid", precision: 38
    t.string "srctblname", limit: 30
    t.decimal "srctblid", precision: 38
    t.decimal "qty_src", precision: 38, scale: 6
    t.string "cno", limit: 40
    t.decimal "trngantts_id", precision: 38, null: false
  end

  create_table "locas", id: :decimal, precision: 38, force: :cascade do |t|
    t.string "code", limit: 40
    t.string "name", limit: 100
    t.string "abbr", limit: 50
    t.string "zip", limit: 10
    t.string "country", limit: 20
    t.string "prfct", limit: 20
    t.string "addr1", limit: 50
    t.string "addr2", limit: 50
    t.string "tel", limit: 20
    t.string "fax", limit: 20
    t.string "mail", limit: 20
    t.string "contents", limit: 4000
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.decimal "persons_id_upd", precision: 38
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.index ["code", "expiredate"], name: "locas_23_uk", unique: true
  end

  create_table "lotstkhists", id: :decimal, precision: 38, force: :cascade do |t|
    t.decimal "itms_id", precision: 38, null: false
    t.datetime "starttime", precision: 6
    t.decimal "processseq", precision: 38
    t.string "lotno", limit: 50
    t.string "packno", limit: 10
    t.decimal "qty_stk", precision: 22, scale: 6
    t.decimal "qty", precision: 22, scale: 6
    t.date "expiredate"
    t.string "remark", limit: 4000
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.decimal "prjnos_id", precision: 38, null: false
    t.string "stktaking_proc", limit: 1
    t.decimal "shelfnos_id", precision: 38
    t.decimal "qty_sch", precision: 22, scale: 6
    t.decimal "shelfnos_id_real", precision: 22, default: "0", null: false
    t.decimal "metcounter", precision: 5
    t.index ["itms_id", "processseq", "shelfnos_id", "prjnos_id", "lotno", "packno", "starttime"], name: "lotstkhists_uky10", unique: true
  end

  create_table "mkacts", id: :decimal, precision: 38, force: :cascade do |t|
    t.string "result_f", limit: 1
    t.decimal "runtime", precision: 2
    t.datetime "isudate", precision: 6
    t.string "prdpurshp", limit: 5
    t.datetime "rcptdate", precision: 6
    t.decimal "qty", precision: 22, scale: 6
    t.decimal "qty_case", precision: 22
    t.decimal "price", precision: 38, scale: 4
    t.decimal "amt", precision: 18, scale: 4
    t.decimal "locas_id_to", precision: 38, null: false
    t.string "contents", limit: 4000
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.datetime "updated_at", precision: 6
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
  end

  create_table "mkordopeitms", id: :decimal, precision: 38, force: :cascade do |t|
    t.decimal "mkords_id", precision: 22, null: false
    t.date "expiredate"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.string "remark", limit: 4000
    t.string "contents", limit: 4000
    t.string "update_ip", limit: 40
    t.decimal "opeitms_id", precision: 38, default: "0", null: false
    t.datetime "toduedate", precision: 6
    t.decimal "shelfnos_id_to", precision: 38, default: "0", null: false
  end

  create_table "mkords", id: :decimal, precision: 38, force: :cascade do |t|
    t.datetime "cmpldate", precision: 6
    t.string "result_f", limit: 1
    t.decimal "runtime", precision: 2
    t.datetime "isudate", precision: 6
    t.string "orgtblname", limit: 30
    t.string "confirm", limit: 1
    t.string "manual", limit: 1
    t.decimal "incnt", precision: 38
    t.decimal "inqty", precision: 22, scale: 6
    t.decimal "inamt", precision: 38, scale: 4
    t.decimal "outcnt", precision: 38
    t.decimal "outqty", precision: 22, scale: 6
    t.decimal "outamt", precision: 38, scale: 4
    t.decimal "skipcnt", precision: 38
    t.decimal "skipqty", precision: 22, scale: 6
    t.decimal "skipamt", precision: 38, scale: 4
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.string "remark", limit: 4000
    t.string "message_code", limit: 256
    t.decimal "persons_id_upd", precision: 38, null: false
    t.datetime "updated_at", precision: 6
    t.string "sno_org", limit: 50
    t.string "sno_pare", limit: 50
    t.string "tblname", limit: 30
    t.string "paretblname", limit: 30
    t.string "itm_code_pare", limit: 50
    t.string "loca_code_org", limit: 50
    t.datetime "duedate_trn", precision: 6
    t.datetime "duedate_pare", precision: 6
    t.datetime "duedate_org", precision: 6
    t.decimal "processseq_org", precision: 22
    t.decimal "processseq_pare", precision: 38
    t.string "itm_code_trn", limit: 50
    t.string "itm_code_org", limit: 50
    t.string "itm_name_org", limit: 100
    t.string "itm_name_trn", limit: 100
    t.string "itm_name_pare", limit: 100
    t.string "person_code_chrg_org", limit: 50
    t.string "person_code_chrg_pare", limit: 50
    t.string "person_code_chrg_trn", limit: 50
    t.string "person_name_chrg_org", limit: 100
    t.string "person_name_chrg_pare", limit: 100
    t.string "person_name_chrg_trn", limit: 100
    t.string "loca_code_pare", limit: 50
    t.string "loca_code_trn", limit: 50
    t.string "loca_name_trn", limit: 100
    t.string "loca_name_pare", limit: 100
    t.decimal "processseq_trn", precision: 38
    t.string "loca_name_org", limit: 100
    t.string "loca_name_to_trn", limit: 100
    t.datetime "starttime_trn", precision: 6
  end

  create_table "mkordterms", id: :decimal, precision: 38, force: :cascade do |t|
    t.decimal "mkords_id", precision: 22, null: false
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.decimal "persons_id_upd", precision: 38, null: false
    t.decimal "itms_id", precision: 38, null: false
    t.datetime "duedate", precision: 6
    t.datetime "toduedate", precision: 6
    t.string "contents", limit: 4000
    t.decimal "locas_id", precision: 38, null: false
    t.decimal "processseq", precision: 38
    t.decimal "prjnos_id", precision: 38, null: false
    t.decimal "shelfnos_id_to", precision: 38, null: false
    t.decimal "mlevel", precision: 3
  end

  create_table "mkordtmpfs", id: :decimal, precision: 38, force: :cascade do |t|
    t.decimal "qty_sch", precision: 22, scale: 6
    t.decimal "mkords_id", precision: 22, null: false
    t.decimal "qty_require", precision: 22, scale: 6
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.decimal "persons_id_upd", precision: 38, null: false
    t.decimal "itms_id", precision: 38, null: false
    t.decimal "qty", precision: 22, scale: 6
    t.datetime "duedate", precision: 6
    t.datetime "toduedate", precision: 6
    t.decimal "packqty", precision: 18, scale: 2
    t.string "contents", limit: 4000
    t.decimal "locas_id", precision: 38, null: false
    t.decimal "processseq", precision: 38
    t.decimal "prjnos_id", precision: 38, null: false
    t.decimal "parenum", precision: 22, scale: 6
    t.decimal "chilnum", precision: 22, scale: 6
    t.decimal "itms_id_pare", precision: 38, null: false
    t.decimal "processseq_pare", precision: 38
    t.decimal "mlevel", precision: 3
    t.decimal "qty_stk", precision: 22, scale: 6
    t.decimal "qty_handover", precision: 22, scale: 6
    t.decimal "shelfnos_id_to", precision: 38, null: false
    t.string "tblname", limit: 30
    t.decimal "tblid", precision: 38
    t.decimal "incnt", precision: 38
    t.decimal "consumminqty", precision: 22, scale: 6
    t.decimal "consumchgoverqty", precision: 22, scale: 6
    t.decimal "consumunitqty", precision: 22, scale: 6
  end

  create_table "mkshps", id: :decimal, precision: 38, force: :cascade do |t|
    t.datetime "cmpldate", precision: 6
    t.string "result_f", limit: 1
    t.decimal "runtime", precision: 2
    t.datetime "isudate", precision: 6
    t.string "confirm", limit: 1
    t.string "manual", limit: 1
    t.string "orgtblname", limit: 30
    t.string "sno_org", limit: 50
    t.decimal "itms_id_org", precision: 38, null: false
    t.decimal "locas_id_org", precision: 38, null: false
    t.string "paretblname", limit: 30
    t.string "duedate_pare", limit: 18
    t.string "sno_pare", limit: 50
    t.decimal "itms_id_pare", precision: 38, null: false
    t.decimal "locas_id_pare", precision: 38, null: false
    t.string "tblname", limit: 30
    t.decimal "incnt", precision: 38
    t.decimal "inqty", precision: 22, scale: 6
    t.decimal "inamt", precision: 38, scale: 4
    t.decimal "outcnt", precision: 38
    t.decimal "outqty", precision: 22, scale: 6
    t.decimal "outamt", precision: 38, scale: 4
    t.decimal "skipcnt", precision: 38
    t.decimal "skipqty", precision: 22, scale: 6
    t.decimal "skipamt", precision: 38, scale: 4
    t.string "remark", limit: 4000
    t.string "message_code", limit: 256
    t.decimal "persons_id_upd", precision: 38, null: false
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.date "expiredate"
    t.string "update_ip", limit: 40
  end

  create_table "nditms", id: :decimal, precision: 38, force: :cascade do |t|
    t.decimal "opeitms_id", precision: 38
    t.decimal "itms_id_nditm", precision: 38
    t.decimal "processseq_nditm", precision: 38
    t.decimal "parenum", precision: 22, scale: 6
    t.decimal "chilnum", precision: 22, scale: 6
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.decimal "persons_id_upd", precision: 38
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.decimal "consumunitqty", precision: 22, scale: 6
    t.string "contents", limit: 4000
    t.string "byproduct", limit: 1
    t.decimal "consumminqty", precision: 22, scale: 6
    t.decimal "consumchgoverqty", precision: 22, scale: 6
    t.decimal "price", precision: 38, scale: 4
    t.decimal "crrs_id", precision: 22
    t.decimal "shelfnos_id_fm", precision: 22, default: "0", null: false
  end

  create_table "opeitms", id: :decimal, precision: 38, force: :cascade do |t|
    t.decimal "processseq", precision: 38
    t.decimal "priority", precision: 38
    t.decimal "itms_id", precision: 38
    t.decimal "packqty", precision: 18, scale: 2
    t.decimal "duration", precision: 38, scale: 2
    t.date "expiredate"
    t.decimal "persons_id_upd", precision: 38
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.string "remark", limit: 4000
    t.string "operation", limit: 40
    t.decimal "maxqty", precision: 22, scale: 6
    t.decimal "safestkqty", precision: 22
    t.string "autocreate_act", limit: 1
    t.string "autocreate_inst", limit: 1
    t.string "contents", limit: 4000
    t.string "shuffle_flg", limit: 1
    t.string "shuffle_loca", limit: 1
    t.decimal "esttosch", precision: 38
    t.string "prdpurshp", limit: 5
    t.string "mold", limit: 1
    t.string "rule_price", limit: 1
    t.decimal "boxes_id", precision: 38
    t.decimal "prjalloc_flg", precision: 38
    t.string "packno_proc", limit: 1
    t.string "units_lttime", limit: 4
    t.decimal "autoinst_p", precision: 3
    t.decimal "autoact_p", precision: 3
    t.string "stktaking_proc", limit: 1
    t.string "lotno_proc", limit: 3
    t.string "chkinst_proc", limit: 1
    t.string "chkord_proc", limit: 3
    t.decimal "locas_id_opeitm", precision: 22, default: "0", null: false
    t.decimal "optfixoterm", precision: 5, scale: 2
    t.string "optfixflg", limit: 1
    t.string "acceptance_proc", limit: 30
    t.decimal "shelfnos_id_to_opeitm", precision: 38, default: "0", null: false
    t.decimal "shelfnos_id_fm_opeitm", precision: 22, default: "0", null: false
    t.decimal "units_id_case_shp", precision: 38, default: "0", null: false
    t.decimal "units_id_case_prdpur", precision: 38, default: "0", null: false
    t.string "consumauto", limit: 1
    t.index ["itms_id", "id"], name: "opeitms_uky3", unique: true
    t.index ["itms_id", "processseq", "priority"], name: "opeitms_uky1", unique: true
  end

  create_table "outamts", id: :decimal, precision: 38, force: :cascade do |t|
    t.datetime "starttime", precision: 6
    t.decimal "amt", precision: 18, scale: 4
    t.decimal "crrs_id", precision: 22, null: false
    t.date "expiredate"
    t.string "remark", limit: 4000
    t.decimal "persons_id_upd", precision: 38, null: false
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.string "update_ip", limit: 40
    t.decimal "locas_id_out", precision: 22
    t.decimal "alloctbls_id", precision: 38
    t.string "inoutflg", limit: 20
  end

  create_table "outstks", id: :decimal, precision: 38, force: :cascade do |t|
    t.datetime "starttime", precision: 6
    t.string "lotno", limit: 50
    t.string "packno", limit: 10
    t.date "expiredate"
    t.string "remark", limit: 4000
    t.decimal "persons_id_upd", precision: 38, null: false
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.string "update_ip", limit: 40
    t.decimal "shelfnos_id_out", precision: 22
    t.string "inoutflg", limit: 20
    t.string "tblname", limit: 30
    t.decimal "tblid", precision: 38
  end

  create_table "payacts", id: :decimal, precision: 38, force: :cascade do |t|
    t.datetime "isudate", precision: 6
    t.datetime "duedate", precision: 6
    t.decimal "price", precision: 38, scale: 4
    t.decimal "tax", precision: 38, scale: 4
    t.string "contract_price", limit: 1
    t.string "itm_code_client", limit: 50
    t.string "sno", limit: 40
    t.string "sno_payinst", limit: 50
    t.decimal "chrgs_id", precision: 38, null: false
    t.decimal "suppliers_id", precision: 22, null: false
    t.decimal "payments_id_pay", precision: 22, null: false
    t.date "expiredate"
    t.string "contents", limit: 4000
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "remark", limit: 4000
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.decimal "cash", precision: 22, scale: 2
  end

  create_table "payinsts", id: :decimal, precision: 38, force: :cascade do |t|
    t.datetime "isudate", precision: 6
    t.datetime "duedate", precision: 6
    t.decimal "price", precision: 38, scale: 4
    t.decimal "amt", precision: 18, scale: 4
    t.decimal "tax", precision: 38, scale: 4
    t.string "contract_price", limit: 1
    t.string "itm_code_client", limit: 50
    t.string "sno", limit: 40
    t.decimal "chrgs_id", precision: 38, null: false
    t.decimal "suppliers_id", precision: 22, null: false
    t.decimal "payments_id_pay", precision: 22, null: false
    t.date "expiredate"
    t.string "contents", limit: 4000
    t.decimal "persons_id_upd", precision: 38, null: false
    t.datetime "created_at", precision: 6
    t.string "update_ip", limit: 40
    t.datetime "updated_at", precision: 6
    t.string "remark", limit: 4000
  end

  create_table "payments", id: :decimal, precision: 38, force: :cascade do |t|
    t.string "personname", limit: 30
    t.decimal "locas_id_payment", precision: 38, null: false
    t.decimal "chrgs_id_payment", precision: 22, null: false
    t.date "expiredate"
    t.string "contents", limit: 4000
    t.string "remark", limit: 4000
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.decimal "crrs_id_payment", precision: 22, default: "0", null: false
  end

  create_table "payords", id: :decimal, precision: 38, force: :cascade do |t|
    t.string "sno_purord", limit: 50
    t.datetime "isudate", precision: 6
    t.datetime "duedate", precision: 6
    t.decimal "qty", precision: 22, scale: 6
    t.decimal "price", precision: 38, scale: 4
    t.decimal "amt", precision: 18, scale: 4
    t.decimal "tax", precision: 38, scale: 4
    t.string "contract_price", limit: 1
    t.string "itm_code_client", limit: 50
    t.string "sno", limit: 40
    t.decimal "chrgs_id", precision: 38, null: false
    t.decimal "suppliers_id", precision: 22, null: false
    t.decimal "payments_id_pay", precision: 22, null: false
    t.decimal "itms_id", precision: 38, null: false
    t.date "expiredate"
    t.string "contents", limit: 4000
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "remark", limit: 4000
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.decimal "crrs_id_payord", precision: 22, default: "0", null: false
    t.string "gno_paysch", limit: 40
    t.string "gno", limit: 40
  end

  create_table "payschs", id: :decimal, precision: 38, force: :cascade do |t|
    t.string "sno", limit: 40
    t.datetime "isudate", precision: 6
    t.datetime "duedate", precision: 6
    t.decimal "price", precision: 38, scale: 4
    t.decimal "tax", precision: 38, scale: 4
    t.string "contract_price", limit: 1
    t.string "itm_code_client", limit: 50
    t.decimal "chrgs_id", precision: 38, null: false
    t.decimal "suppliers_id", precision: 22, null: false
    t.decimal "itms_id", precision: 38, null: false
    t.date "expiredate"
    t.string "contents", limit: 4000
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.string "remark", limit: 4000
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.decimal "payments_id_pay", precision: 22
    t.decimal "qty_sch", precision: 22, scale: 6
    t.decimal "amt_sch", precision: 38, scale: 4
    t.string "gno", limit: 40
  end

  create_table "persons", id: :decimal, precision: 38, force: :cascade do |t|
    t.string "code", limit: 10
    t.string "name", limit: 50
    t.decimal "usrgrps_id", precision: 38
    t.decimal "sects_id", precision: 38
    t.decimal "scrlvs_id", precision: 38
    t.string "contents", limit: 4000
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.decimal "persons_id_upd", precision: 38
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.string "email", limit: 40
    t.index ["code"], name: "persons_16_uk", unique: true
    t.index ["email"], name: "persons_uky1", unique: true
  end

  create_table "pobjects", id: :decimal, precision: 38, force: :cascade do |t|
    t.string "remark", limit: 4000
    t.decimal "persons_id_upd", precision: 38
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.date "expiredate"
    t.datetime "updated_at", precision: 6
    t.string "code", limit: 50
    t.string "contents", limit: 4000
    t.string "objecttype", limit: 19
    t.index ["code", "objecttype"], name: "pobjects_ukys1", unique: true
  end

  create_table "pobjgrps", id: :decimal, precision: 38, force: :cascade do |t|
    t.decimal "pobjects_id", precision: 38
    t.decimal "usrgrps_id", precision: 38
    t.string "name", limit: 50
    t.string "contents", limit: 4000
    t.string "remark", limit: 4000
    t.decimal "persons_id_upd", precision: 38
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.date "expiredate"
    t.datetime "updated_at", precision: 6
    t.index ["usrgrps_id", "name", "expiredate"], name: "pobjgrps_uky1", unique: true
  end

  create_table "prdacts", id: :decimal, precision: 38, force: :cascade do |t|
    t.datetime "isudate", precision: 6
    t.datetime "cmpldate", precision: 6
    t.string "sno", limit: 40
    t.string "cno", limit: 40
    t.string "gno", limit: 40
    t.string "lotno", limit: 50
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "contents", limit: 4000
    t.decimal "opeitms_id", precision: 38, null: false
    t.decimal "prjnos_id", precision: 38, null: false
    t.decimal "chrgs_id", precision: 38, null: false
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.decimal "shelfnos_id_to", precision: 38
    t.decimal "qty_stk", precision: 22, scale: 6
    t.string "sno_prdord", limit: 50
    t.string "sno_prdinst", limit: 50
    t.string "cno_prdinst", limit: 50
    t.decimal "workplaces_id", precision: 22
    t.string "packno", limit: 10
    t.decimal "crrs_id_prdact", precision: 22, default: "0", null: false
    t.decimal "shelfnos_id_fm", precision: 22, default: "0", null: false
  end

  create_table "prdests", id: :decimal, precision: 38, force: :cascade do |t|
    t.string "contents", limit: 4000
    t.datetime "isudate", precision: 6
    t.datetime "starttime", precision: 6
    t.decimal "locas_id_to", precision: 38, null: false
    t.decimal "processseq_pare", precision: 38
    t.datetime "duedate", precision: 6
    t.datetime "toduedate", precision: 6
    t.decimal "qty", precision: 22, scale: 6
    t.decimal "tax", precision: 38, scale: 4
    t.datetime "updated_at", precision: 6
    t.string "sno", limit: 40
    t.date "expiredate"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "remark", limit: 4000
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.decimal "chrgs_id", precision: 38, null: false
    t.decimal "opeitms_id", precision: 38, null: false
    t.decimal "prjnos_id", precision: 38, null: false
  end

  create_table "prdinsts", id: :decimal, precision: 38, force: :cascade do |t|
    t.datetime "isudate", precision: 6
    t.datetime "duedate", precision: 6
    t.decimal "qty_case", precision: 22
    t.decimal "qty", precision: 22, scale: 6
    t.decimal "locas_id_to", precision: 38, null: false
    t.datetime "commencementdate", precision: 6
    t.string "commencement_f", limit: 1
    t.string "sno", limit: 40
    t.string "cno", limit: 40
    t.string "gno", limit: 40
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.decimal "prjnos_id", precision: 38, null: false
    t.decimal "chrgs_id", precision: 38, null: false
    t.decimal "opeitms_id", precision: 38, null: false
    t.string "contents", limit: 4000
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.string "sno_prdord", limit: 50
    t.decimal "shelfnos_id_to", precision: 38
    t.decimal "workplaces_id", precision: 22
    t.datetime "starttime", precision: 6
    t.decimal "shelfnos_id_fm", precision: 22, default: "0", null: false
  end

  create_table "prdords", id: :decimal, precision: 38, force: :cascade do |t|
    t.string "confirm", limit: 1
    t.datetime "isudate", precision: 6
    t.datetime "starttime", precision: 6
    t.datetime "duedate", precision: 6
    t.decimal "qty", precision: 22, scale: 6
    t.decimal "chrgs_id", precision: 38
    t.string "sno", limit: 40
    t.string "gno", limit: 40
    t.decimal "prjnos_id", precision: 38
    t.decimal "autoinst_p", precision: 3
    t.decimal "autoact_p", precision: 3
    t.date "expiredate"
    t.string "remark", limit: 4000
    t.datetime "toduedate", precision: 6
    t.decimal "persons_id_upd", precision: 38
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.string "update_ip", limit: 40
    t.decimal "qty_case", precision: 22
    t.decimal "opeitms_id", precision: 38
    t.decimal "shelfnos_id_to", precision: 38
    t.decimal "workplaces_id", precision: 22
    t.string "sno_prdsch", limit: 50
    t.decimal "crrs_id_prdord", precision: 22, default: "0", null: false
    t.string "gno_prdsch", limit: 50
    t.decimal "shelfnos_id_fm", precision: 22, default: "0", null: false
  end

  create_table "prdreplyinputs", id: :decimal, precision: 38, force: :cascade do |t|
    t.string "result_f", limit: 1
    t.datetime "isudate", precision: 6
    t.decimal "qty", precision: 22, scale: 6
    t.decimal "qty_case", precision: 22
    t.decimal "locas_id_to", precision: 38, null: false
    t.string "remark", limit: 4000
    t.string "contents", limit: 4000
    t.date "expiredate"
    t.string "message_code", limit: 256
    t.decimal "opeitms_id", precision: 38, null: false
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.string "sno_prdord", limit: 50
    t.string "sno_prdinst", limit: 50
    t.date "replydate"
    t.string "cno", limit: 40
    t.decimal "shelfnos_id_fm", precision: 22, default: "0", null: false
  end

  create_table "prdrets", id: :decimal, precision: 38, force: :cascade do |t|
    t.datetime "isudate", precision: 6
    t.date "retdate"
    t.decimal "locas_id_fm", precision: 38, null: false
    t.decimal "locas_id_to", precision: 38, null: false
    t.decimal "qty_case", precision: 22
    t.decimal "qty", precision: 22, scale: 6
    t.decimal "tax", precision: 38, scale: 4
    t.string "sno", limit: 40
    t.string "contents", limit: 4000
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.decimal "prjnos_id", precision: 38, null: false
    t.decimal "opeitms_id", precision: 38, null: false
    t.decimal "chrgs_id", precision: 38, null: false
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.string "sno_prdact", limit: 50
  end

  create_table "prdrsltinputs", id: :decimal, precision: 38, force: :cascade do |t|
    t.string "result_f", limit: 1
    t.string "sno", limit: 40
    t.datetime "isudate", precision: 6
    t.datetime "cmpldate", precision: 6
    t.decimal "qty", precision: 22, scale: 6
    t.string "cno", limit: 40
    t.decimal "qty_case", precision: 22
    t.string "sno_prdord", limit: 50
    t.string "sno_prdinst", limit: 50
    t.decimal "price", precision: 38, scale: 4
    t.decimal "amt", precision: 18, scale: 4
    t.decimal "tax", precision: 38, scale: 4
    t.string "remark", limit: 4000
    t.string "contents", limit: 4000
    t.date "expiredate"
    t.string "message_code", limit: 256
    t.decimal "opeitms_id", precision: 38, null: false
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.string "sno_prdreplyinput", limit: 50
    t.decimal "shelfnos_id_fm", precision: 22, default: "0", null: false
  end

  create_table "prdschs", id: :decimal, precision: 38, force: :cascade do |t|
    t.datetime "starttime", precision: 6
    t.datetime "isudate", precision: 6
    t.datetime "duedate", precision: 6
    t.datetime "toduedate", precision: 6
    t.datetime "updated_at", precision: 6
    t.string "sno", limit: 40
    t.date "expiredate"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "remark", limit: 4000
    t.datetime "created_at", precision: 6
    t.string "update_ip", limit: 40
    t.decimal "prjnos_id", precision: 38, null: false
    t.decimal "chrgs_id", precision: 38, null: false
    t.decimal "opeitms_id", precision: 38
    t.decimal "shelfnos_id_to", precision: 38
    t.decimal "workplaces_id", precision: 22
    t.decimal "qty_sch", precision: 22, scale: 6
    t.string "gno", limit: 40
    t.decimal "shelfnos_id_fm", precision: 22, default: "0", null: false
  end

  create_table "prdstrs", id: :decimal, precision: 38, force: :cascade do |t|
    t.datetime "isudate", precision: 6
    t.datetime "starttime", precision: 6
    t.decimal "qty_case", precision: 22
    t.decimal "qty", precision: 22, scale: 6
    t.string "sno", limit: 40
    t.string "cno", limit: 40
    t.string "gno", limit: 40
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "contents", limit: 4000
    t.decimal "chrgs_id", precision: 38, null: false
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.string "sno_prdord", limit: 50
  end

  create_table "pricemsts", id: :decimal, precision: 38, force: :cascade do |t|
    t.string "tblname", limit: 30
    t.date "expiredate"
    t.decimal "maxqty", precision: 22, scale: 6
    t.decimal "price", precision: 38, scale: 4
    t.decimal "amtdecimal", precision: 38
    t.string "amtround", limit: 2
    t.string "contract_price", limit: 1
    t.string "rule_price", limit: 1
    t.string "over_f", limit: 1
    t.string "itm_code_client", limit: 50
    t.string "contents", limit: 4000
    t.string "update_ip", limit: 40
    t.decimal "itms_id", precision: 38, null: false
    t.decimal "locas_id", precision: 38, null: false
    t.decimal "chrgs_id", precision: 38, null: false
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "remark", limit: 4000
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.decimal "processseq", precision: 38
  end

  create_table "prjnos", id: :decimal, precision: 38, force: :cascade do |t|
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.decimal "persons_id_upd", precision: 38
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.string "name", limit: 100
    t.string "code", limit: 50
    t.decimal "prjnos_id_chil", precision: 38, default: "0", null: false
    t.string "contents", limit: 4000
    t.decimal "priority", precision: 38, default: "0", null: false
  end

  create_table "processcontrols", id: :decimal, precision: 38, force: :cascade do |t|
    t.string "tblname", limit: 30
    t.decimal "seqno", precision: 38
    t.string "destblname", limit: 30
    t.string "segment", limit: 10
    t.string "rubycode", limit: 4000
    t.string "contents", limit: 4000
    t.string "remark", limit: 4000
    t.decimal "persons_id_upd", precision: 38
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.date "expiredate"
  end

  create_table "processreqs", id: :decimal, precision: 38, force: :cascade do |t|
    t.string "tblname", limit: 30
    t.decimal "tblid", precision: 38
    t.string "result_f", limit: 1
    t.string "update_ip", limit: 40
    t.string "contents", limit: 4000
    t.string "remark", limit: 4000
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.decimal "persons_id_upd", precision: 38
    t.string "reqparams", limit: 8192
    t.decimal "seqno", precision: 38
  end

  create_table "puracts", id: :decimal, precision: 38, force: :cascade do |t|
    t.string "sno", limit: 40
    t.datetime "isudate", precision: 6
    t.datetime "rcptdate", precision: 6
    t.string "cno", limit: 40
    t.string "itm_code_client", limit: 50
    t.string "lotno", limit: 50
    t.string "contents", limit: 4000
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.decimal "chrgs_id", precision: 38, null: false
    t.decimal "prjnos_id", precision: 38, null: false
    t.decimal "opeitms_id", precision: 38, null: false
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.decimal "suppliers_id", precision: 22
    t.string "sno_purinst", limit: 50
    t.string "sno_purord", limit: 50
    t.string "sno_purdlv", limit: 50
    t.string "cno_purinst", limit: 50
    t.string "cno_purdlv", limit: 50
    t.decimal "qty_stk", precision: 22, scale: 6
    t.decimal "shelfnos_id_to", precision: 38
    t.string "packno", limit: 10
    t.decimal "crrs_id_puract", precision: 22, default: "0", null: false
    t.decimal "amt", precision: 18, scale: 4
    t.decimal "shelfnos_id_fm", precision: 22, default: "0", null: false
    t.string "invoiceno", limit: 50
    t.string "cartonno", limit: 50
  end

  create_table "purdlvs", id: :decimal, precision: 38, force: :cascade do |t|
    t.datetime "isudate", precision: 6
    t.decimal "suppliers_id", precision: 22, null: false
    t.datetime "depdate", precision: 6
    t.decimal "qty_case", precision: 22
    t.string "itm_code_client", limit: 50
    t.string "sno", limit: 40
    t.string "cno", limit: 40
    t.string "gno", limit: 40
    t.decimal "autoact_p", precision: 3
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.decimal "chrgs_id", precision: 38, null: false
    t.decimal "prjnos_id", precision: 38, null: false
    t.decimal "opeitms_id", precision: 38, null: false
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.string "sno_purinst", limit: 50
    t.string "cno_purinst", limit: 50
    t.decimal "shelfnos_id_to", precision: 38, null: false
    t.string "sno_purord", limit: 50
    t.decimal "shelfnos_id_fm", precision: 22, default: "0", null: false
    t.string "cno_purord", limit: 50
    t.string "sno_purreplyinput", limit: 50
    t.string "cno_purreplyinput", limit: 50
    t.string "invoiceno", limit: 50
    t.string "cartonno", limit: 50
    t.decimal "qty_stk", precision: 22, scale: 6
  end

  create_table "purests", id: :decimal, precision: 38, force: :cascade do |t|
    t.string "contents", limit: 4000
    t.string "confirm", limit: 1
    t.decimal "locas_id_to", precision: 38, null: false
    t.decimal "processseq_pare", precision: 38
    t.datetime "isudate", precision: 6
    t.datetime "starttime", precision: 6
    t.datetime "duedate", precision: 6
    t.datetime "toduedate", precision: 6
    t.decimal "qty", precision: 22, scale: 6
    t.decimal "price", precision: 38, scale: 4
    t.decimal "amt", precision: 18, scale: 4
    t.decimal "tax", precision: 38, scale: 4
    t.string "sno", limit: 40
    t.date "expiredate"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "remark", limit: 4000
    t.datetime "updated_at", precision: 6
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.decimal "chrgs_id", precision: 38, null: false
    t.decimal "opeitms_id", precision: 38, null: false
    t.decimal "prjnos_id", precision: 38, null: false
    t.decimal "suppliers_id", precision: 22, null: false
    t.decimal "crrs_id", precision: 22, null: false
  end

  create_table "purinsts", id: :decimal, precision: 38, force: :cascade do |t|
    t.datetime "isudate", precision: 6
    t.decimal "suppliers_id", precision: 22, null: false
    t.datetime "duedate", precision: 6
    t.decimal "qty", precision: 22, scale: 6
    t.decimal "qty_case", precision: 22
    t.decimal "price", precision: 38, scale: 4
    t.decimal "amt", precision: 18, scale: 4
    t.decimal "tax", precision: 38, scale: 4
    t.string "itm_code_client", limit: 50
    t.string "sno", limit: 40
    t.string "cno", limit: 40
    t.decimal "autoact_p", precision: 3
    t.string "contract_price", limit: 1
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.decimal "chrgs_id", precision: 38, null: false
    t.decimal "opeitms_id", precision: 38, null: false
    t.decimal "prjnos_id", precision: 38, null: false
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.string "sno_purord", limit: 50
    t.decimal "shelfnos_id_to", precision: 38
    t.datetime "starttime", precision: 6
    t.decimal "shelfnos_id_fm", precision: 22, default: "0", null: false
  end

  create_table "purords", id: :decimal, precision: 38, force: :cascade do |t|
    t.string "sno", limit: 40, null: false
    t.decimal "qty", precision: 22, scale: 6
    t.datetime "duedate", precision: 6
    t.datetime "isudate", precision: 6
    t.string "remark", limit: 4000
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.decimal "amt", precision: 18, scale: 4
    t.datetime "toduedate", precision: 6
    t.decimal "persons_id_upd", precision: 38
    t.date "expiredate"
    t.decimal "price", precision: 38, scale: 4
    t.decimal "qty_case", precision: 22
    t.string "confirm", limit: 1
    t.decimal "prjnos_id", precision: 38
    t.string "contract_price", limit: 1
    t.decimal "chrgs_id", precision: 38
    t.decimal "tax", precision: 38, scale: 4
    t.string "gno", limit: 40, null: false
    t.string "itm_code_client", limit: 50
    t.datetime "starttime", precision: 6
    t.decimal "autoinst_p", precision: 3
    t.decimal "autoact_p", precision: 3
    t.decimal "suppliers_id", precision: 22
    t.decimal "opeitms_id", precision: 38
    t.decimal "shelfnos_id_to", precision: 38
    t.decimal "crrs_id_purord", precision: 22, default: "0", null: false
    t.decimal "shelfnos_id_fm", precision: 22, default: "0", null: false
  end

  create_table "purreplyinputs", id: :decimal, precision: 38, force: :cascade do |t|
    t.datetime "isudate", precision: 6
    t.decimal "qty", precision: 22, scale: 6
    t.decimal "qty_case", precision: 22
    t.string "sno", limit: 40
    t.string "remark", limit: 4000
    t.string "contents", limit: 4000
    t.date "expiredate"
    t.string "message_code", limit: 256
    t.decimal "opeitms_id", precision: 38, null: false
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.date "replydate"
    t.string "sno_purinst", limit: 50
    t.string "cno", limit: 40
    t.string "sno_purord", limit: 50
    t.decimal "shelfnos_id_fm", precision: 22, default: "0", null: false
    t.decimal "shelfnos_id_to", precision: 38, default: "0", null: false
  end

  create_table "purrets", id: :decimal, precision: 38, force: :cascade do |t|
    t.datetime "isudate", precision: 6
    t.date "retdate"
    t.decimal "locas_id_fm", precision: 38, null: false
    t.decimal "qty_case", precision: 22
    t.decimal "qty", precision: 22, scale: 6
    t.decimal "price", precision: 38, scale: 4
    t.decimal "amt", precision: 18, scale: 4
    t.decimal "tax", precision: 38, scale: 4
    t.string "sno", limit: 40
    t.string "contract_price", limit: 1
    t.string "contents", limit: 4000
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.decimal "opeitms_id", precision: 38, null: false
    t.decimal "prjnos_id", precision: 38, null: false
    t.decimal "chrgs_id", precision: 38, null: false
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.decimal "suppliers_id", precision: 22, null: false
    t.decimal "crrs_id", precision: 22, null: false
    t.string "sno_puract", limit: 50
  end

  create_table "purrsltinputs", id: :decimal, precision: 38, force: :cascade do |t|
    t.string "result_f", limit: 1
    t.datetime "isudate", precision: 6
    t.datetime "rcptdate", precision: 6
    t.decimal "qty", precision: 22, scale: 6
    t.decimal "qty_case", precision: 22
    t.string "sno", limit: 40
    t.string "sno_purord", limit: 50
    t.string "sno_purinst", limit: 50
    t.string "cno_purinst", limit: 50
    t.string "contents", limit: 4000
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "message_code", limit: 256
    t.decimal "opeitms_id", precision: 38, null: false
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.decimal "crrs_id", precision: 22, null: false
    t.string "sno_purreplyinput", limit: 50
    t.decimal "shelfnos_id_fm", precision: 22, default: "0", null: false
    t.decimal "shelfnos_id_to", precision: 38, default: "0", null: false
    t.string "invoiceno", limit: 50
    t.string "cartonno", limit: 50
  end

  create_table "purschs", id: :decimal, precision: 38, force: :cascade do |t|
    t.datetime "isudate", precision: 6
    t.datetime "starttime", precision: 6
    t.datetime "duedate", precision: 6
    t.datetime "toduedate", precision: 6
    t.decimal "price", precision: 38, scale: 4
    t.decimal "tax", precision: 38, scale: 4
    t.string "sno", limit: 40
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.decimal "prjnos_id", precision: 38, null: false
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.decimal "opeitms_id", precision: 38
    t.decimal "suppliers_id", precision: 22
    t.decimal "shelfnos_id_to", precision: 38
    t.decimal "chrgs_id", precision: 38
    t.decimal "qty_sch", precision: 22, scale: 6
    t.decimal "amt_sch", precision: 38, scale: 4
    t.string "gno", limit: 40
    t.decimal "shelfnos_id_fm", precision: 22, default: "0", null: false
  end

  create_table "reasons", id: :decimal, precision: 38, force: :cascade do |t|
    t.string "code", limit: 50, null: false
    t.string "name", limit: 100, null: false
    t.string "contents", limit: 4000
    t.string "remark", limit: 4000
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
  end

  create_table "reports", id: :decimal, precision: 38, force: :cascade do |t|
    t.string "filename", limit: 50
    t.decimal "screens_id", precision: 38
    t.decimal "usrgrps_id", precision: 38
    t.date "expiredate"
    t.string "remark", limit: 4000
    t.decimal "persons_id_upd", precision: 38
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.decimal "pobjects_id_rep", precision: 38
    t.string "contents", limit: 4000
  end

  create_table "rubycodings", id: :decimal, precision: 38, force: :cascade do |t|
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.decimal "persons_id_upd", precision: 38
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.string "codel", limit: 100
    t.string "contents", limit: 4000
    t.decimal "pobjects_id", precision: 38
    t.string "rubycode", limit: 4000
    t.string "hikisu", limit: 400
    t.index ["codel", "expiredate"], name: "rubycodings_ukys1", unique: true
  end

  create_table "rules", id: :decimal, precision: 38, force: :cascade do |t|
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.decimal "persons_id_upd", precision: 38
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.string "contents", limit: 4000
    t.decimal "pobjects_id", precision: 38
  end

  create_table "schofmkords", id: :decimal, precision: 38, force: :cascade do |t|
    t.decimal "mkords_id", precision: 22, null: false
    t.decimal "trngantts_id", precision: 38, null: false
    t.decimal "itms_id", precision: 38, null: false
    t.decimal "processseq", precision: 38
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "updated_at", precision: 6
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "contents", limit: 4000
    t.string "remark", limit: 4000
    t.datetime "created_at", precision: 6
  end

  create_table "screenfields", id: :decimal, precision: 38, force: :cascade do |t|
    t.decimal "screens_id", precision: 38
    t.decimal "selection", precision: 38
    t.decimal "hideflg", precision: 38
    t.decimal "seqno", precision: 38
    t.decimal "rowpos", precision: 38
    t.decimal "colpos", precision: 38
    t.decimal "width", precision: 38
    t.string "type", limit: 12
    t.decimal "dataprecision", precision: 38
    t.decimal "datascale", precision: 38
    t.decimal "indisp", precision: 38
    t.decimal "editable", precision: 38
    t.decimal "maxvalue", precision: 38
    t.decimal "minvalue", precision: 38
    t.decimal "edoptsize", precision: 38
    t.decimal "edoptmaxlength", precision: 38
    t.decimal "edoptrow", precision: 38
    t.decimal "edoptcols", precision: 38
    t.string "edoptvalue", limit: 800
    t.string "sumkey", limit: 1
    t.string "crtfield", limit: 100
    t.date "expiredate"
    t.string "remark", limit: 4000
    t.decimal "persons_id_upd", precision: 38
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.decimal "pobjects_id_sfd", precision: 38
    t.decimal "tblfields_id", precision: 38
    t.string "paragraph", limit: 30
    t.string "formatter", limit: 4000
    t.string "contents", limit: 4000
    t.string "subindisp", limit: 100
    t.index ["paragraph", "id"], name: "screenfields_uky2", unique: true
    t.index ["pobjects_id_sfd", "screens_id"], name: "screenfields_uky3", unique: true
    t.index ["screens_id", "pobjects_id_sfd"], name: "screenfields_uky1", unique: true
  end

  create_table "screens", id: :decimal, precision: 38, force: :cascade do |t|
    t.string "strselect", limit: 4000
    t.string "strwhere", limit: 4000
    t.string "strgrouporder", limit: 4000
    t.string "ymlcode", limit: 4000
    t.string "cdrflayout", limit: 10
    t.date "expiredate"
    t.string "remark", limit: 4000
    t.decimal "persons_id_upd", precision: 38
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.decimal "pobjects_id_scr", precision: 38
    t.decimal "pobjects_id_view", precision: 38
    t.decimal "pobjects_id_sgrp", precision: 38
    t.decimal "seqno", precision: 38
    t.decimal "rows_per_page", precision: 38
    t.string "rowlist", limit: 30
    t.decimal "height", precision: 38
    t.string "form_ps", limit: 4000
    t.decimal "scrlvs_id", precision: 38
    t.string "contents", limit: 4000
    t.string "strorder", limit: 4000
    t.decimal "width", precision: 38
    t.index ["pobjects_id_scr"], name: "screens_ukys1", unique: true
  end

  create_table "scrlvs", id: :decimal, precision: 38, force: :cascade do |t|
    t.string "code", limit: 50
    t.datetime "created_at", precision: 6
    t.date "expiredate"
    t.string "level1", limit: 1
    t.decimal "persons_id_upd", precision: 38
    t.string "contents", limit: 4000
    t.string "remark", limit: 4000
    t.string "update_ip", limit: 4
    t.datetime "updated_at", precision: 6
    t.index ["code", "expiredate"], name: "scrlvs_23_uk", unique: true
  end

  create_table "sects", id: :decimal, precision: 38, force: :cascade do |t|
    t.decimal "locas_id_sect", precision: 38
    t.string "contents", limit: 4000
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.decimal "persons_id_upd", precision: 38
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
  end

  create_table "shelfnos", id: :decimal, precision: 38, force: :cascade do |t|
    t.string "contents", limit: 4000
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.decimal "persons_id_upd", precision: 38
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.string "code", limit: 50
    t.decimal "locas_id_shelfno", precision: 38
    t.string "name", limit: 100
    t.string "update_ip", limit: 40
    t.index ["locas_id_shelfno", "code"], name: "shelfnos_ukys10", unique: true
  end

  create_table "shpacts", id: :decimal, precision: 38, force: :cascade do |t|
    t.string "sno", limit: 40
    t.datetime "starttime", precision: 6
    t.datetime "duedate", precision: 6
    t.datetime "isudate", precision: 6
    t.string "gno", limit: 40
    t.decimal "qty", precision: 22, scale: 6
    t.decimal "qty_case", precision: 22
    t.string "cno", limit: 40
    t.string "cartonno", limit: 50
    t.decimal "price", precision: 38, scale: 4
    t.string "contract_price", limit: 1
    t.decimal "amt", precision: 18, scale: 4
    t.decimal "tax", precision: 38, scale: 4
    t.string "box", limit: 50
    t.string "contents", limit: 4000
    t.date "expiredate"
    t.string "remark", limit: 4000
    t.decimal "transports_id", precision: 38, null: false
    t.decimal "persons_id_upd", precision: 38, null: false
    t.decimal "prjnos_id", precision: 38, null: false
    t.decimal "chrgs_id", precision: 38, null: false
    t.datetime "created_at", precision: 6
    t.string "update_ip", limit: 40
    t.datetime "updated_at", precision: 6
    t.decimal "processseq", precision: 38
    t.decimal "itms_id", precision: 38, null: false
    t.string "paretblname", limit: 30
    t.decimal "paretblid", precision: 38
    t.decimal "qty_stk", precision: 22, scale: 6
    t.decimal "crrs_id", precision: 22, null: false
    t.decimal "units_id_case_shp", precision: 38, default: "0", null: false
    t.string "consumauto", limit: 1
    t.decimal "shelfnos_id_to", precision: 38, default: "0", null: false
    t.decimal "qty_shp", precision: 38
  end

  create_table "shpests", id: :decimal, precision: 38, force: :cascade do |t|
    t.string "contents", limit: 4000
    t.datetime "isudate", precision: 6
    t.datetime "duedate", precision: 6
    t.datetime "starttime", precision: 6
    t.datetime "toduedate", precision: 6
    t.decimal "locas_id_to", precision: 38, null: false
    t.decimal "qty", precision: 22, scale: 6
    t.decimal "price", precision: 38, scale: 4
    t.decimal "amt", precision: 18, scale: 4
    t.decimal "tax", precision: 38, scale: 4
    t.string "contract_price", limit: 1
    t.string "sno", limit: 40
    t.date "expiredate"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "remark", limit: 4000
    t.datetime "created_at", precision: 6
    t.string "update_ip", limit: 40
    t.datetime "updated_at", precision: 6
    t.decimal "chrgs_id", precision: 38, null: false
    t.decimal "prjnos_id", precision: 38, null: false
    t.decimal "opeitms_id", precision: 38, null: false
  end

  create_table "shpinsts", id: :decimal, precision: 38, force: :cascade do |t|
    t.string "sno", limit: 40
    t.decimal "itms_id", precision: 38, null: false
    t.decimal "qty_shortage", precision: 22, scale: 5
    t.datetime "starttime", precision: 6
    t.datetime "isudate", precision: 6
    t.string "gno", limit: 40
    t.decimal "paretblid", precision: 38
    t.string "paretblname", limit: 30
    t.decimal "locas_id_to", precision: 38, null: false
    t.decimal "qty_case", precision: 22
    t.string "cno", limit: 40
    t.decimal "processseq", precision: 38
    t.string "cartonno", limit: 20
    t.string "box", limit: 50
    t.decimal "price", precision: 38, scale: 4
    t.string "contract_price", limit: 1
    t.decimal "amt", precision: 18, scale: 4
    t.decimal "tax", precision: 38, scale: 4
    t.string "contents", limit: 4000
    t.date "expiredate"
    t.string "remark", limit: 4000
    t.decimal "persons_id_upd", precision: 38, null: false
    t.decimal "chrgs_id", precision: 38, null: false
    t.decimal "prjnos_id", precision: 38, null: false
    t.decimal "transports_id", precision: 38, null: false
    t.datetime "created_at", precision: 6
    t.string "update_ip", limit: 40
    t.datetime "updated_at", precision: 6
    t.decimal "qty_stk", precision: 22, scale: 6
    t.decimal "shelfnos_id_fm", precision: 22, null: false
    t.datetime "depdate", precision: 6
    t.decimal "units_id_case_shp", precision: 38, default: "0", null: false
    t.string "consumauto", limit: 1
    t.decimal "shelfnos_id_to", precision: 38, default: "0", null: false
    t.decimal "qty_shp", precision: 38
  end

  create_table "shpords", id: :decimal, precision: 38, force: :cascade do |t|
    t.datetime "isudate", precision: 6
    t.decimal "itms_id", precision: 38, null: false
    t.decimal "shelfnos_id_fm", precision: 22, null: false
    t.decimal "locas_id_to", precision: 38, null: false
    t.decimal "transports_id", precision: 38, null: false
    t.date "expiredate"
    t.datetime "depdate", precision: 6
    t.decimal "qty", precision: 22, scale: 6
    t.decimal "price", precision: 38, scale: 4
    t.decimal "tax", precision: 38, scale: 4
    t.string "contract_price", limit: 1
    t.decimal "prjnos_id", precision: 38, null: false
    t.string "manual", limit: 1
    t.string "lotno", limit: 50
    t.decimal "qty_case", precision: 22
    t.string "packno", limit: 10
    t.string "gno", limit: 40
    t.string "sno", limit: 40
    t.decimal "chrgs_id", precision: 38, null: false
    t.string "paretblname", limit: 30
    t.decimal "paretblid", precision: 38
    t.string "remark", limit: 4000
    t.decimal "persons_id_upd", precision: 38, null: false
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.string "update_ip", limit: 40
    t.decimal "processseq", precision: 38
    t.decimal "amt", precision: 18, scale: 4
    t.decimal "crrs_id_shpord", precision: 22, default: "0", null: false
    t.decimal "qty_shortage", precision: 22, scale: 5
    t.datetime "duedate", precision: 6
    t.string "consumauto", limit: 1
    t.decimal "shelfnos_id_to", precision: 38, default: "0", null: false
  end

  create_table "shpreplyinputs", id: :decimal, precision: 38, force: :cascade do |t|
    t.string "result_f", limit: 1
    t.datetime "isudate", precision: 6
    t.datetime "starttime", precision: 6
    t.datetime "duedate", precision: 6
    t.decimal "qty", precision: 22, scale: 6
    t.decimal "qty_case", precision: 22
    t.decimal "qty_case_bal", precision: 38
    t.string "sno", limit: 40
    t.decimal "locas_id_to", precision: 38, null: false
    t.string "box", limit: 50
    t.string "cartonno", limit: 20
    t.string "siosession", limit: 20
    t.string "remark", limit: 4000
    t.string "contents", limit: 4000
    t.date "expiredate"
    t.string "message_code", limit: 256
    t.decimal "transports_id", precision: 38, null: false
    t.decimal "opeitms_id", precision: 38, null: false
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
  end

  create_table "shprets", id: :decimal, precision: 38, force: :cascade do |t|
    t.datetime "isudate", precision: 6
    t.date "retdate"
    t.decimal "qty_case", precision: 22
    t.decimal "price", precision: 38, scale: 4
    t.decimal "amt", precision: 18, scale: 4
    t.decimal "tax", precision: 38, scale: 4
    t.string "sno", limit: 40
    t.string "contract_price", limit: 1
    t.decimal "crrs_id", precision: 22, null: false
    t.string "contents", limit: 4000
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.decimal "chrgs_id", precision: 38, null: false
    t.decimal "prjnos_id", precision: 38, null: false
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.decimal "shelfnos_id_fm", precision: 22, default: "0", null: false
    t.decimal "itms_id", precision: 38, default: "0", null: false
    t.decimal "processseq", precision: 38
    t.decimal "qty_stk", precision: 22, scale: 6
    t.decimal "shelfnos_id_to", precision: 38, default: "0", null: false
  end

  create_table "shprsltinputs", id: :decimal, precision: 38, force: :cascade do |t|
    t.string "result_f", limit: 1
    t.datetime "duedate", precision: 6
    t.datetime "isudate", precision: 6
    t.datetime "starttime", precision: 6
    t.decimal "qty", precision: 22, scale: 6
    t.decimal "qty_case", precision: 22
    t.decimal "qty_case_bal", precision: 38
    t.decimal "locas_id_to", precision: 38, null: false
    t.decimal "shelfnos_id_fm", precision: 22, null: false
    t.string "sno", limit: 40
    t.string "box", limit: 50
    t.decimal "crrs_id", precision: 22, null: false
    t.string "siosession", limit: 20
    t.string "cartonno", limit: 20
    t.string "contents", limit: 4000
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "message_code", limit: 256
    t.decimal "transports_id", precision: 38, null: false
    t.decimal "opeitms_id", precision: 38, null: false
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
  end

  create_table "shpschs", id: :decimal, precision: 38, force: :cascade do |t|
    t.datetime "isudate", precision: 6
    t.string "manual", limit: 1
    t.decimal "price", precision: 38, scale: 4
    t.decimal "tax", precision: 38, scale: 4
    t.string "contract_price", limit: 1
    t.string "sno", limit: 40
    t.date "expiredate"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "remark", limit: 4000
    t.datetime "updated_at", precision: 6
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.decimal "prjnos_id", precision: 38, null: false
    t.decimal "chrgs_id", precision: 38, null: false
    t.decimal "transports_id", precision: 38, null: false
    t.decimal "itms_id", precision: 38
    t.decimal "locas_id_to", precision: 38
    t.datetime "depdate", precision: 6
    t.string "lotno", limit: 50
    t.string "packno", limit: 10
    t.string "paretblname", limit: 30
    t.decimal "paretblid", precision: 38
    t.decimal "shelfnos_id_fm", precision: 22
    t.decimal "processseq", precision: 38
    t.decimal "qty_sch", precision: 22, scale: 6
    t.decimal "qty_case", precision: 22
    t.decimal "amt_sch", precision: 38, scale: 4
    t.string "gno", limit: 40
    t.datetime "duedate", precision: 6
    t.string "consumauto", limit: 1
    t.decimal "shelfnos_id_to", precision: 38, default: "0", null: false
  end

  create_table "srctbls", id: :decimal, precision: 38, force: :cascade do |t|
    t.string "srctblname", limit: 30
    t.string "sno", limit: 40
    t.string "cno", limit: 40
    t.decimal "srctblid", precision: 38
    t.decimal "qty_src", precision: 38, scale: 6
    t.string "contents", limit: 4000
    t.date "expiredate"
    t.string "remark", limit: 4000
    t.decimal "persons_id_upd", precision: 38, null: false
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.string "update_ip", limit: 40
    t.string "tblname", limit: 30
    t.decimal "tblid", precision: 38
  end

  create_table "suppliers", id: :decimal, precision: 38, force: :cascade do |t|
    t.string "personname", limit: 30
    t.string "custtype", limit: 1
    t.decimal "crrs_id_supplier", precision: 22, null: false
    t.decimal "locas_id_supplier", precision: 22, null: false
    t.decimal "chrgs_id_supplier", precision: 22, null: false
    t.string "contract_price", limit: 1
    t.string "rule_price", limit: 1
    t.string "amtround", limit: 2
    t.decimal "amtdecimal", precision: 38
    t.string "contents", limit: 4000
    t.date "expiredate"
    t.string "remark", limit: 4000
    t.decimal "payments_id", precision: 38, null: false
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.datetime "updated_at", precision: 6
    t.datetime "created_at", precision: 6
  end

  create_table "supplierwhs", id: :decimal, precision: 38, force: :cascade do |t|
    t.decimal "suppliers_id", precision: 22, null: false
    t.decimal "qty_sch", precision: 22, scale: 6
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.decimal "persons_id_upd", precision: 38, null: false
    t.decimal "itms_id", precision: 38, null: false
    t.decimal "qty", precision: 22, scale: 6
    t.datetime "depdate", precision: 6
    t.decimal "processseq", precision: 38
    t.string "lotno", limit: 50
    t.decimal "qty_stk", precision: 22, scale: 6
  end

  create_table "table_opeitms", id: :decimal, precision: 22, force: :cascade do |t|
    t.string "itm_code", limit: 50
    t.string "opeitm_processseq", limit: 3
    t.string "opeitm_priority", limit: 3
    t.string "itm_name", limit: 100
    t.string "loca_code", limit: 50
    t.string "loca_name", limit: 100
    t.string "opeitm_prdpurshp", limit: 20
    t.string "opeitm_operation", limit: 20
    t.string "unit_code", limit: 50
    t.string "unit_name", limit: 100
    t.string "unit_code_case", limit: 50
    t.string "unit_name_case", limit: 100
    t.string "unit_code_prdpurshp", limit: 50
    t.string "unit_name_prdpurshp", limit: 100
    t.string "boxe_code", limit: 50
    t.string "boxe_name", limit: 100
    t.string "unit_code_box", limit: 50
    t.string "unit_name_box", limit: 100
    t.string "unit_code_outbox", limit: 50
    t.string "unit_name_outbox", limit: 100
    t.string "shelfno_code", limit: 50
    t.string "shelfno_name", limit: 100
    t.string "loca_code_shelfno", limit: 50
    t.string "loca_name_shelfno", limit: 100
    t.string "classlist_code", limit: 50
    t.string "classlist_name", limit: 100
    t.string "opeitm_duration", limit: 38
    t.string "opeitm_autocreate_ord", limit: 1
    t.string "opeitm_acceptance_proc", limit: 1
    t.string "opeitm_opt_fixoterm", limit: 8
    t.string "opeitm_stktaking_proc", limit: 1
    t.string "opeitm_autoinst_p", limit: 3
    t.string "opeitm_rule_price", limit: 1
    t.string "opeitm_autocreate_act", limit: 1
    t.string "opeitm_shuffle_loca", limit: 1
    t.string "opeitm_shuffle_flg", limit: 1
    t.string "opeitm_autocreate_inst", limit: 1
    t.string "opeitm_packno_flg", limit: 1
    t.string "opeitm_packqty", limit: 38
    t.string "opeitm_minqty", limit: 38
    t.string "opeitm_maxqty", limit: 22
    t.string "opeitm_safestkqty", limit: 38
    t.string "opeitm_units_lttime", limit: 4
    t.string "opeitm_chkord", limit: 1
    t.string "opeitm_chkord_prc", limit: 3
    t.string "opeitm_esttosch", limit: 22
    t.string "itm_std", limit: 50
    t.string "itm_model", limit: 50
    t.string "itm_material", limit: 50
    t.string "itm_design", limit: 50
    t.string "itm_weight", limit: 22
    t.string "itm_length", limit: 22
    t.string "itm_wide", limit: 22
    t.string "itm_deth", limit: 22
    t.string "itm_datascale", limit: 22
    t.string "unit_contents", limit: 4000
    t.string "unit_dataprecision_prdpurshp", limit: 38
    t.string "unit_dataprecision_case", limit: 38
    t.string "opeitm_chkinst", limit: 1
    t.string "opeitm_mold", limit: 1
    t.string "opeitm_prjalloc_flg", limit: 22
    t.string "opeitm_autoord_p", limit: 3
    t.string "opeitm_autoact_p", limit: 3
    t.string "opeitm_opt_fix_flg", limit: 1
    t.string "unit_contents_prdpurshp", limit: 4000
    t.string "unit_contents_case", limit: 4000
    t.string "opeitm_expiredate", limit: 50
    t.string "boxe_boxtype", limit: 20
    t.string "opeitm_contents", limit: 4000
    t.string "opeitm_remark", limit: 4000
    t.decimal "opeitm_created_at", precision: 38
    t.decimal "opeitm_loca_id", precision: 38
    t.decimal "opeitm_id", precision: 38
    t.decimal "opeitm_person_id_upd", precision: 38
    t.string "opeitm_update_ip", limit: 40
    t.decimal "opeitm_unit_id_prdpurshp", precision: 38
    t.decimal "opeitm_itm_id", precision: 38
    t.decimal "boxe_unit_id_outbox", precision: 38
    t.decimal "boxe_unit_id_box", precision: 38
    t.decimal "itm_unit_id", precision: 22
    t.decimal "itm_classlist_id", precision: 38
    t.string "loca_zip_shelfno", limit: 10
    t.decimal "opeitm_shelfno_id", precision: 22
    t.string "opeitm_updated_at", limit: 50
    t.string "loca_abbr_shelfno", limit: 50
    t.string "shelfno_contents", limit: 4000
    t.string "boxe_depth", limit: 7
    t.string "boxe_wide", limit: 7
    t.string "boxe_height", limit: 7
    t.string "boxe_outdepth", limit: 7
    t.string "boxe_outwide", limit: 7
    t.string "boxe_outheight", limit: 7
    t.string "loca_abbr", limit: 50
    t.string "loca_mail", limit: 20
    t.string "loca_mail_shelfno", limit: 20
    t.string "loca_fax", limit: 20
    t.string "loca_fax_shelfno", limit: 20
    t.string "person_code_upd", limit: 50
    t.string "person_name_upd", limit: 100
    t.decimal "shelfno_loca_id_shelfno", precision: 38
    t.string "loca_tel", limit: 20
    t.string "loca_tel_shelfno", limit: 20
    t.string "loca_addr2", limit: 50
    t.string "loca_addr2_shelfno", limit: 50
    t.decimal "opeitm_unit_id_case", precision: 38
    t.string "loca_addr1", limit: 50
    t.string "loca_addr1_shelfno", limit: 50
    t.string "loca_prfct", limit: 20
    t.string "loca_prfct_shelfno", limit: 20
    t.string "boxe_contents", limit: 4000
    t.string "loca_country", limit: 20
    t.decimal "opeitm_boxe_id", precision: 22
    t.string "loca_country_shelfno", limit: 20
    t.string "loca_zip", limit: 10
  end

  create_table "tblfields", id: :decimal, precision: 38, force: :cascade do |t|
    t.decimal "blktbs_id", precision: 38
    t.decimal "fieldcodes_id", precision: 38
    t.date "expiredate"
    t.string "remark", limit: 4000
    t.decimal "persons_id_upd", precision: 38
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.decimal "seqno", precision: 38
    t.string "contents", limit: 4000
    t.string "viewflmk", limit: 4000
    t.index ["blktbs_id", "fieldcodes_id"], name: "tblfields_ukys10", unique: true
  end

  create_table "tblinkflds", id: :decimal, precision: 38, force: :cascade do |t|
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.decimal "persons_id_upd", precision: 38
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.string "command_c", limit: 4000
    t.decimal "tblinks_id", precision: 38
    t.decimal "tblfields_id", precision: 38
    t.decimal "seqno", precision: 38
    t.string "contents", limit: 4000
    t.string "rubycode", limit: 4000
    t.index ["tblinks_id", "tblfields_id"], name: "tblinkflds_ukys10", unique: true
  end

  create_table "tblinks", id: :decimal, precision: 38, force: :cascade do |t|
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.decimal "persons_id_upd", precision: 38
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.decimal "blktbs_id_dest", precision: 38
    t.decimal "screens_id_src", precision: 38
    t.decimal "seqno", precision: 38
    t.string "beforeafter", limit: 15
    t.string "contents", limit: 4000
    t.string "hikisu", limit: 400
    t.string "codel", limit: 50
    t.index ["screens_id_src", "blktbs_id_dest", "beforeafter", "seqno"], name: "tblinks_ukys1", unique: true
  end

  create_table "transports", id: :decimal, precision: 38, force: :cascade do |t|
    t.string "code", limit: 50, null: false
    t.string "name", limit: 100, null: false
    t.string "contents", limit: 4000
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "updated_at", precision: 6
    t.decimal "persons_id_upd", precision: 38, null: false
    t.datetime "created_at", precision: 6
  end

  create_table "trngantts", id: :decimal, precision: 38, force: :cascade do |t|
    t.string "key", limit: 250
    t.string "orgtblname", limit: 30
    t.decimal "orgtblid", precision: 38
    t.string "paretblname", limit: 30
    t.decimal "paretblid", precision: 38
    t.string "tblname", limit: 30
    t.decimal "tblid", precision: 38
    t.decimal "qty", precision: 22, scale: 6
    t.decimal "qty_stk", precision: 22, scale: 6
    t.decimal "qty_alloc", precision: 22, scale: 6
    t.decimal "mlevel", precision: 3
    t.decimal "parenum", precision: 22, scale: 6
    t.decimal "chilnum", precision: 22, scale: 6
    t.string "shuffle_flg", limit: 1
    t.decimal "consumunitqty", precision: 22, scale: 6
    t.decimal "consumminqty", precision: 22, scale: 6
    t.decimal "consumchgoverqty", precision: 22, scale: 6
    t.string "remark", limit: 4000
    t.datetime "created_at", precision: 6
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "updated_at", precision: 6
    t.decimal "persons_id_upd", precision: 38
    t.decimal "prjnos_id", precision: 38
    t.decimal "processseq_pare", precision: 38
    t.decimal "locas_id_pare", precision: 38
    t.decimal "itms_id_pare", precision: 38
    t.decimal "qty_stk_pare", precision: 22, scale: 6
    t.decimal "qty_pare", precision: 22, scale: 6
    t.decimal "qty_pare_alloc", precision: 22, scale: 6
    t.decimal "qty_bal", precision: 22, scale: 6
    t.decimal "qty_pare_bal", precision: 22, scale: 6
    t.datetime "duedate_org", precision: 6
    t.decimal "qty_sch", precision: 22, scale: 6
    t.decimal "mkords_id_trngantt", precision: 22, default: "0", null: false
    t.datetime "starttime_org", precision: 6
    t.datetime "starttime_pare", precision: 6
    t.decimal "itms_id_org", precision: 38, default: "0", null: false
    t.decimal "locas_id_org", precision: 38, default: "0", null: false
    t.datetime "duedate_trn", precision: 6
    t.datetime "duedate_pare", precision: 6
    t.decimal "chrgs_id_pare", precision: 22, default: "0", null: false
    t.decimal "chrgs_id_org", precision: 38, default: "0", null: false
    t.decimal "chrgs_id_trn", precision: 38, default: "0", null: false
    t.decimal "processseq_org", precision: 22
    t.decimal "locas_id_trn", precision: 38, default: "0", null: false
    t.decimal "itms_id_trn", precision: 38, default: "0", null: false
    t.decimal "processseq_trn", precision: 38
    t.datetime "starttime_trn", precision: 6
    t.decimal "qty_require", precision: 22, scale: 6
    t.decimal "qty_handover", precision: 22, scale: 6
    t.decimal "shelfnos_id_to", precision: 38, default: "0", null: false
    t.decimal "qty_free", precision: 22, scale: 6
    t.index ["orgtblname", "orgtblid", "key", "paretblname", "paretblid", "tblname", "tblid"], name: "trngantts_ukyg1", unique: true
  end

  create_table "units", id: :decimal, precision: 38, force: :cascade do |t|
    t.string "code", limit: 50
    t.string "name", limit: 100
    t.string "remark", limit: 4000
    t.decimal "persons_id_upd", precision: 38
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.string "contents", limit: 4000
    t.decimal "dataprecision", precision: 38
  end

  create_table "uploads", force: :cascade do |t|
    t.string "title"
    t.string "contents"
    t.string "result"
    t.string "persons_id_upd"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "usebuttons", id: :decimal, precision: 38, force: :cascade do |t|
    t.decimal "buttons_id", precision: 38
    t.date "expiredate"
    t.string "contents", limit: 4000
    t.string "remark", limit: 4000
    t.decimal "persons_id_upd", precision: 38
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.decimal "screens_id_ub", precision: 38
  end

  create_table "userprocs", id: :decimal, precision: 38, force: :cascade do |t|
    t.decimal "session_counter", precision: 38
    t.string "sio_code", limit: 30
    t.string "status", limit: 256
    t.decimal "cnt", precision: 38
    t.decimal "cnt_out", precision: 38
    t.decimal "persons_id_upd", precision: 38
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.date "expiredate"
    t.datetime "updated_at", precision: 6
    t.index ["session_counter", "sio_code"], name: "userprocs_uk1", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "provider", default: "email", null: false
    t.string "uid", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.boolean "allow_password_change", default: false
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "name"
    t.string "nickname"
    t.string "image"
    t.string "email"
    t.json "tokens"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
  end

  create_table "usrgrps", id: :decimal, precision: 38, force: :cascade do |t|
    t.string "code", limit: 10
    t.string "name", limit: 50
    t.string "email", limit: 50
    t.string "contents", limit: 4000
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.decimal "persons_id_upd", precision: 38
    t.string "update_ip", limit: 40
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.index ["code", "expiredate"], name: "usrgrps_16_uk", unique: true
  end

  create_table "workplaces", id: :decimal, precision: 38, force: :cascade do |t|
    t.decimal "locas_id_workplace", precision: 22, null: false
    t.decimal "chrgs_id_workplace", precision: 22, null: false
    t.string "contents", limit: 4000
    t.date "expiredate"
    t.string "remark", limit: 4000
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.datetime "updated_at", precision: 6
    t.datetime "created_at", precision: 6
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "alloctbls", "persons", column: "persons_id_upd", name: "alloctbl_persons_id_upd"
  add_foreign_key "alloctbls", "trngantts", column: "trngantts_id", name: "alloctbl_trngantts_id"
  add_foreign_key "asstwhs", "chrgs", column: "chrgs_id_asstwh", name: "asstwh_chrgs_id_asstwh"
  add_foreign_key "asstwhs", "locas", column: "locas_id_asstwh", name: "asstwh_locas_id_asstwh"
  add_foreign_key "asstwhs", "persons", column: "persons_id_upd", name: "asstwh_persons_id_upd"
  add_foreign_key "billacts", "bills", column: "bills_id", name: "billact_bills_id"
  add_foreign_key "billacts", "itms", column: "itms_id", name: "billact_itms_id"
  add_foreign_key "billacts", "persons", column: "persons_id_upd", name: "billact_persons_id_upd"
  add_foreign_key "billinsts", "bills", column: "bills_id", name: "billinst_bills_id"
  add_foreign_key "billinsts", "itms", column: "itms_id", name: "billinst_itms_id"
  add_foreign_key "billinsts", "persons", column: "persons_id_upd", name: "billinst_persons_id_upd"
  add_foreign_key "billords", "bills", column: "bills_id", name: "billord_bills_id"
  add_foreign_key "billords", "crrs", column: "crrs_id_billord", name: "billord_crrs_id_billord"
  add_foreign_key "billords", "itms", column: "itms_id", name: "billord_itms_id"
  add_foreign_key "billords", "locas", column: "locas_id_to", name: "billord_locas_id_to"
  add_foreign_key "billords", "persons", column: "persons_id_upd", name: "billord_persons_id_upd"
  add_foreign_key "bills", "chrgs", column: "chrgs_id_bill", name: "bill_chrgs_id_bill"
  add_foreign_key "bills", "crrs", column: "crrs_id_bill", name: "bill_crrs_id_bill"
  add_foreign_key "bills", "locas", column: "locas_id_bill", name: "bill_locas_id_bill"
  add_foreign_key "bills", "persons", column: "persons_id_upd", name: "bill_persons_id_upd"
  add_foreign_key "billschs", "bills", column: "bills_id", name: "billsch_bills_id"
  add_foreign_key "billschs", "itms", column: "itms_id", name: "billsch_itms_id"
  add_foreign_key "billschs", "persons", column: "persons_id_upd", name: "billsch_persons_id_upd"
  add_foreign_key "blktbs", "persons", column: "persons_id_upd", name: "blktb_persons_id_upd"
  add_foreign_key "blktbs", "pobjects", column: "pobjects_id_tbl", name: "blktb_pobjects_id_tbl"
  add_foreign_key "blkukys", "persons", column: "persons_id_upd", name: "blkuky_persons_id_upd"
  add_foreign_key "blkukys", "tblfields", column: "tblfields_id", name: "blkuky_tblfields_id"
  add_foreign_key "boxes", "persons", column: "persons_id_upd", name: "boxe_persons_id_upd"
  add_foreign_key "boxes", "units", column: "units_id_box", name: "boxe_units_id_box"
  add_foreign_key "boxes", "units", column: "units_id_outbox", name: "boxe_units_id_outbox"
  add_foreign_key "buttons", "persons", column: "persons_id_upd", name: "button_persons_id_upd"
  add_foreign_key "chilscreens", "persons", column: "persons_id_upd", name: "chilscreen_persons_id_upd"
  add_foreign_key "chilscreens", "screenfields", column: "screenfields_id", name: "chilscreen_screenfields_id"
  add_foreign_key "chilscreens", "screenfields", column: "screenfields_id_ch", name: "chilscreen_screenfields_id_ch"
  add_foreign_key "chrgs", "persons", column: "persons_id_chrg", name: "chrg_persons_id_chrg"
  add_foreign_key "chrgs", "persons", column: "persons_id_upd", name: "chrg_persons_id_upd"
  add_foreign_key "classlists", "persons", column: "persons_id_upd", name: "classlist_persons_id_upd"
  add_foreign_key "conacts", "itms", column: "itms_id", name: "conact_itms_id"
  add_foreign_key "conacts", "persons", column: "persons_id_upd", name: "conact_persons_id_upd"
  add_foreign_key "conacts", "shelfnos", column: "shelfnos_id_fm", name: "conact_shelfnos_id_fm"
  add_foreign_key "coninsts", "itms", column: "itms_id", name: "coninst_itms_id"
  add_foreign_key "coninsts", "persons", column: "persons_id_upd", name: "coninst_persons_id_upd"
  add_foreign_key "coninsts", "shelfnos", column: "shelfnos_id_fm", name: "coninst_shelfnos_id_fm"
  add_foreign_key "conords", "itms", column: "itms_id", name: "conord_itms_id"
  add_foreign_key "conords", "persons", column: "persons_id_upd", name: "conord_persons_id_upd"
  add_foreign_key "conords", "shelfnos", column: "shelfnos_id_fm", name: "conord_shelfnos_id_fm"
  add_foreign_key "conschs", "itms", column: "itms_id", name: "consch_itms_id"
  add_foreign_key "conschs", "persons", column: "persons_id_upd", name: "consch_persons_id_upd"
  add_foreign_key "conschs", "shelfnos", column: "shelfnos_id_fm", name: "consch_shelfnos_id_fm"
  add_foreign_key "crrs", "persons", column: "persons_id_upd", name: "crr_persons_id_upd"
  add_foreign_key "custacts", "chrgs", column: "chrgs_id_custord", name: "custact_chrgs_id_custord"
  add_foreign_key "custacts", "custrcvplcs", column: "custrcvplcs_id", name: "custact_custrcvplcs_id"
  add_foreign_key "custacts", "custs", column: "custs_id", name: "custact_custs_id"
  add_foreign_key "custacts", "opeitms", column: "opeitms_id", name: "custact_opeitms_id"
  add_foreign_key "custacts", "persons", column: "persons_id_upd", name: "custact_persons_id_upd"
  add_foreign_key "custacts", "shelfnos", column: "shelfnos_id_fm", name: "custact_shelfnos_id_fm"
  add_foreign_key "custdlvs", "chrgs", column: "chrgs_id_custord", name: "custdlv_chrgs_id_custord"
  add_foreign_key "custdlvs", "custrcvplcs", column: "custrcvplcs_id", name: "custdlv_custrcvplcs_id"
  add_foreign_key "custdlvs", "custs", column: "custs_id", name: "custdlv_custs_id"
  add_foreign_key "custdlvs", "opeitms", column: "opeitms_id", name: "custdlv_opeitms_id"
  add_foreign_key "custdlvs", "persons", column: "persons_id_upd", name: "custdlv_persons_id_upd"
  add_foreign_key "custdlvs", "shelfnos", column: "shelfnos_id_fm", name: "custdlv_shelfnos_id_fm"
  add_foreign_key "custinsts", "chrgs", column: "chrgs_id_custord", name: "custinst_chrgs_id_custord"
  add_foreign_key "custinsts", "custrcvplcs", column: "custrcvplcs_id", name: "custinst_custrcvplcs_id"
  add_foreign_key "custinsts", "custs", column: "custs_id", name: "custinst_custs_id"
  add_foreign_key "custinsts", "opeitms", column: "opeitms_id", name: "custinst_opeitms_id"
  add_foreign_key "custinsts", "persons", column: "persons_id_upd", name: "custinst_persons_id_upd"
  add_foreign_key "custinsts", "shelfnos", column: "shelfnos_id_fm", name: "custinst_shelfnos_id_fm"
  add_foreign_key "custords", "chrgs", column: "chrgs_id_custord", name: "custord_chrgs_id_custord"
  add_foreign_key "custords", "crrs", column: "crrs_id_custord", name: "custord_crrs_id_custord"
  add_foreign_key "custords", "custrcvplcs", column: "custrcvplcs_id", name: "custord_custrcvplcs_id"
  add_foreign_key "custords", "custs", column: "custs_id", name: "custord_custs_id"
  add_foreign_key "custords", "opeitms", column: "opeitms_id", name: "custord_opeitms_id"
  add_foreign_key "custords", "persons", column: "persons_id_upd", name: "custord_persons_id_upd"
  add_foreign_key "custords", "prjnos", column: "prjnos_id", name: "custord_prjnos_id"
  add_foreign_key "custords", "shelfnos", column: "shelfnos_id_fm", name: "custord_shelfnos_id_fm"
  add_foreign_key "custrcvplcs", "locas", column: "locas_id_custrcvplc", name: "custrcvplc_locas_id_custrcvplc"
  add_foreign_key "custrcvplcs", "persons", column: "persons_id_upd", name: "custrcvplc_persons_id_upd"
  add_foreign_key "custrets", "chrgs", column: "chrgs_id_custord", name: "custret_chrgs_id_custord"
  add_foreign_key "custrets", "custrcvplcs", column: "custrcvplcs_id", name: "custret_custrcvplcs_id"
  add_foreign_key "custrets", "custs", column: "custs_id", name: "custret_custs_id"
  add_foreign_key "custrets", "opeitms", column: "opeitms_id", name: "custret_opeitms_id"
  add_foreign_key "custrets", "persons", column: "persons_id_upd", name: "custret_persons_id_upd"
  add_foreign_key "custrets", "shelfnos", column: "shelfnos_id_to", name: "custret_shelfnos_id_to"
  add_foreign_key "custs", "bills", column: "bills_id", name: "cust_bills_id"
  add_foreign_key "custs", "chrgs", column: "chrgs_id_cust", name: "cust_chrgs_id_cust"
  add_foreign_key "custs", "crrs", column: "crrs_id_cust", name: "cust_crrs_id_cust"
  add_foreign_key "custs", "locas", column: "locas_id_cust", name: "cust_locas_id_cust"
  add_foreign_key "custs", "persons", column: "persons_id_upd", name: "cust_persons_id_upd"
  add_foreign_key "custschs", "custrcvplcs", column: "custrcvplcs_id", name: "custsch_custrcvplcs_id"
  add_foreign_key "custschs", "custs", column: "custs_id", name: "custsch_custs_id"
  add_foreign_key "custschs", "opeitms", column: "opeitms_id", name: "custsch_opeitms_id"
  add_foreign_key "custschs", "persons", column: "persons_id_upd", name: "custsch_persons_id_upd"
  add_foreign_key "custschs", "prjnos", column: "prjnos_id", name: "custsch_prjnos_id"
  add_foreign_key "custschs", "shelfnos", column: "shelfnos_id_fm", name: "custsch_shelfnos_id_fm"
  add_foreign_key "custwhs", "custrcvplcs", column: "custrcvplcs_id", name: "custwh_custrcvplcs_id"
  add_foreign_key "custwhs", "itms", column: "itms_id", name: "custwh_itms_id"
  add_foreign_key "custwhs", "persons", column: "persons_id_upd", name: "custwh_persons_id_upd"
  add_foreign_key "dlvacts", "asstwhs", column: "asstwhs_id", name: "dlvact_asstwhs_id"
  add_foreign_key "dlvacts", "custrcvplcs", column: "custrcvplcs_id", name: "dlvact_custrcvplcs_id"
  add_foreign_key "dlvacts", "itms", column: "itms_id", name: "dlvact_itms_id"
  add_foreign_key "dlvacts", "locas", column: "locas_id_to", name: "dlvact_locas_id_to"
  add_foreign_key "dlvacts", "persons", column: "persons_id_upd", name: "dlvact_persons_id_upd"
  add_foreign_key "dlvacts", "prjnos", column: "prjnos_id", name: "dlvact_prjnos_id"
  add_foreign_key "dlvacts", "transports", column: "transports_id", name: "dlvact_transports_id"
  add_foreign_key "dlvinsts", "asstwhs", column: "asstwhs_id", name: "dlvinst_asstwhs_id"
  add_foreign_key "dlvinsts", "custrcvplcs", column: "custrcvplcs_id", name: "dlvinst_custrcvplcs_id"
  add_foreign_key "dlvinsts", "itms", column: "itms_id", name: "dlvinst_itms_id"
  add_foreign_key "dlvinsts", "locas", column: "locas_id_to", name: "dlvinst_locas_id_to"
  add_foreign_key "dlvinsts", "persons", column: "persons_id_upd", name: "dlvinst_persons_id_upd"
  add_foreign_key "dlvinsts", "prjnos", column: "prjnos_id", name: "dlvinst_prjnos_id"
  add_foreign_key "dlvinsts", "transports", column: "transports_id", name: "dlvinst_transports_id"
  add_foreign_key "dlvords", "custs", column: "custs_id", name: "dlvord_custs_id"
  add_foreign_key "dlvords", "itms", column: "itms_id", name: "dlvord_itms_id"
  add_foreign_key "dlvords", "locas", column: "locas_id_fm", name: "dlvord_locas_id_fm"
  add_foreign_key "dlvords", "locas", column: "locas_id_to", name: "dlvord_locas_id_to"
  add_foreign_key "dlvords", "persons", column: "persons_id_upd", name: "dlvord_persons_id_upd"
  add_foreign_key "dlvords", "prjnos", column: "prjnos_id", name: "dlvord_prjnos_id"
  add_foreign_key "dlvords", "transports", column: "transports_id", name: "dlvord_transports_id"
  add_foreign_key "dlvschs", "itms", column: "itms_id", name: "dlvsch_itms_id"
  add_foreign_key "dlvschs", "locas", column: "locas_id_fm", name: "dlvsch_locas_id_fm"
  add_foreign_key "dlvschs", "locas", column: "locas_id_to", name: "dlvsch_locas_id_to"
  add_foreign_key "dlvschs", "persons", column: "persons_id_upd", name: "dlvsch_persons_id_upd"
  add_foreign_key "dlvschs", "prjnos", column: "prjnos_id", name: "dlvsch_prjnos_id"
  add_foreign_key "dlvschs", "transports", column: "transports_id", name: "dlvsch_transports_id"
  add_foreign_key "fieldcodes", "persons", column: "persons_id_upd", name: "fieldcode_persons_id_upd"
  add_foreign_key "fieldcodes", "pobjects", column: "pobjects_id_fld", name: "fieldcode_pobject_id_fld"
  add_foreign_key "inamts", "alloctbls", column: "alloctbls_id", name: "inamt_alloctbls_id"
  add_foreign_key "inamts", "crrs", column: "crrs_id", name: "inamt_crrs_id"
  add_foreign_key "inamts", "locas", column: "locas_id_in", name: "inamt_locas_id_in"
  add_foreign_key "inamts", "persons", column: "persons_id_upd", name: "inamt_persons_id_upd"
  add_foreign_key "incustwhs", "alloctbls", column: "alloctbls_id", name: "incustwh_alloctbls_id"
  add_foreign_key "incustwhs", "custrcvplcs", column: "custrcvplcs_id", name: "incustwh_custrcvplcs_id"
  add_foreign_key "incustwhs", "persons", column: "persons_id_upd", name: "incustwh_persons_id_upd"
  add_foreign_key "inoutlotstks", "persons", column: "persons_id_upd", name: "inoutlotstk_persons_id_upd"
  add_foreign_key "inoutlotstks", "trngantts", column: "trngantts_id", name: "inoutlotstk_trngantts_id"
  add_foreign_key "inspacts", "chrgs", column: "chrgs_id", name: "inspact_chrgs_id"
  add_foreign_key "inspacts", "locas", column: "locas_id_to", name: "inspact_locas_id_to"
  add_foreign_key "inspacts", "opeitms", column: "opeitms_id", name: "inspact_opeitms_id"
  add_foreign_key "inspacts", "persons", column: "persons_id_upd", name: "inspact_persons_id_upd"
  add_foreign_key "inspacts", "prjnos", column: "prjnos_id", name: "inspact_prjnos_id"
  add_foreign_key "inspacts", "reasons", column: "reasons_id", name: "inspact_reasons_id"
  add_foreign_key "inspacts", "shelfnos", column: "shelfnos_id_act", name: "inspact_shelfnos_id_act"
  add_foreign_key "inspacts", "suppliers", column: "suppliers_id", name: "inspact_suppliers_id"
  add_foreign_key "inspinsts", "chrgs", column: "chrgs_id", name: "inspinst_chrgs_id"
  add_foreign_key "inspinsts", "locas", column: "locas_id_to", name: "inspinst_locas_id_to"
  add_foreign_key "inspinsts", "opeitms", column: "opeitms_id", name: "inspinst_opeitms_id"
  add_foreign_key "inspinsts", "persons", column: "persons_id_upd", name: "inspinst_persons_id_upd"
  add_foreign_key "inspinsts", "prjnos", column: "prjnos_id", name: "inspinst_prjnos_id"
  add_foreign_key "inspinsts", "reasons", column: "reasons_id", name: "inspinst_reasons_id"
  add_foreign_key "inspinsts", "suppliers", column: "suppliers_id", name: "inspinst_suppliers_id"
  add_foreign_key "inspords", "chrgs", column: "chrgs_id", name: "inspord_chrgs_id"
  add_foreign_key "inspords", "itms", column: "itms_id", name: "inspord_itms_id"
  add_foreign_key "inspords", "persons", column: "persons_id_upd", name: "inspord_persons_id_upd"
  add_foreign_key "inspords", "prjnos", column: "prjnos_id", name: "inspord_prjnos_id"
  add_foreign_key "inspords", "reasons", column: "reasons_id", name: "inspord_reasons_id"
  add_foreign_key "inspords", "shelfnos", column: "shelfnos_id_fm", name: "inspord_shelfnos_id_fm"
  add_foreign_key "inspords", "shelfnos", column: "shelfnos_id_to", name: "inspord_shelfnos_id_to"
  add_foreign_key "inspords", "suppliers", column: "suppliers_id", name: "inspord_suppliers_id"
  add_foreign_key "inspschs", "chrgs", column: "chrgs_id", name: "inspsch_chrgs_id"
  add_foreign_key "inspschs", "locas", column: "locas_id_to", name: "inspsch_locas_id_to"
  add_foreign_key "inspschs", "opeitms", column: "opeitms_id", name: "inspsch_opeitms_id"
  add_foreign_key "inspschs", "persons", column: "persons_id_upd", name: "inspsch_persons_id_upd"
  add_foreign_key "inspschs", "prjnos", column: "prjnos_id", name: "inspsch_prjnos_id"
  add_foreign_key "inspschs", "suppliers", column: "suppliers_id", name: "inspsch_suppliers_id"
  add_foreign_key "instks", "persons", column: "persons_id_upd", name: "instk_persons_id_upd"
  add_foreign_key "instks", "shelfnos", column: "shelfnos_id_in", name: "instk_shelfnos_id_in"
  add_foreign_key "itms", "classlists", column: "classlists_id", name: "itm_classlists_id"
  add_foreign_key "itms", "persons", column: "persons_id_upd", name: "itm_persons_id_upd"
  add_foreign_key "itms", "units", column: "units_id", name: "itm_units_id"
  add_foreign_key "linktbls", "persons", column: "persons_id_upd", name: "linktbl_persons_id_upd"
  add_foreign_key "linktbls", "trngantts", column: "trngantts_id", name: "linktbl_trngantts_id"
  add_foreign_key "lotstkhists", "itms", column: "itms_id", name: "lotstkhist_itms_id"
  add_foreign_key "lotstkhists", "persons", column: "persons_id_upd", name: "lotstkhist_persons_id_upd"
  add_foreign_key "lotstkhists", "prjnos", column: "prjnos_id", name: "lotstkhist_prjnos_id"
  add_foreign_key "lotstkhists", "shelfnos", column: "shelfnos_id", name: "lotstkhist_shelfnos_id"
  add_foreign_key "lotstkhists", "shelfnos", column: "shelfnos_id_real", name: "lotstkhist_shelfnos_id_real"
  add_foreign_key "mkordopeitms", "mkords", column: "mkords_id", name: "mkordopeitm_mkords_id"
  add_foreign_key "mkordopeitms", "opeitms", column: "opeitms_id", name: "mkordopeitm_opeitms_id"
  add_foreign_key "mkordopeitms", "persons", column: "persons_id_upd", name: "mkordopeitm_persons_id_upd"
  add_foreign_key "mkordopeitms", "shelfnos", column: "shelfnos_id_to", name: "mkordopeitm_shelfnos_id_to"
  add_foreign_key "mkords", "persons", column: "persons_id_upd", name: "mkord_persons_id_upd"
  add_foreign_key "mkordterms", "itms", column: "itms_id", name: "mkordterm_itms_id"
  add_foreign_key "mkordterms", "locas", column: "locas_id", name: "mkordterm_locas_id"
  add_foreign_key "mkordterms", "mkords", column: "mkords_id", name: "mkordterm_mkords_id"
  add_foreign_key "mkordterms", "persons", column: "persons_id_upd", name: "mkordterm_persons_id_upd"
  add_foreign_key "mkordterms", "prjnos", column: "prjnos_id", name: "mkordterm_prjnos_id"
  add_foreign_key "mkordterms", "shelfnos", column: "shelfnos_id_to", name: "mkordterm_shelfnos_id_to"
  add_foreign_key "mkordtmpfs", "itms", column: "itms_id", name: "mkordtmpf_itms_id"
  add_foreign_key "mkordtmpfs", "itms", column: "itms_id_pare", name: "mkordtmpf_itms_id_pare"
  add_foreign_key "mkordtmpfs", "locas", column: "locas_id", name: "mkordtmpf_locas_id"
  add_foreign_key "mkordtmpfs", "mkords", column: "mkords_id", name: "mkordtmpf_mkords_id"
  add_foreign_key "mkordtmpfs", "persons", column: "persons_id_upd", name: "mkordtmpf_persons_id_upd"
  add_foreign_key "mkordtmpfs", "prjnos", column: "prjnos_id", name: "mkordtmpf_prjnos_id"
  add_foreign_key "mkordtmpfs", "shelfnos", column: "shelfnos_id_to", name: "mkordtmpf_shelfnos_id_to"
  add_foreign_key "mkshps", "itms", column: "itms_id_org", name: "mkshp_itms_id_org"
  add_foreign_key "mkshps", "itms", column: "itms_id_pare", name: "mkshp_itms_id_pare"
  add_foreign_key "mkshps", "locas", column: "locas_id_org", name: "mkshp_locas_id_org"
  add_foreign_key "mkshps", "locas", column: "locas_id_pare", name: "mkshp_locas_id_pare"
  add_foreign_key "mkshps", "persons", column: "persons_id_upd", name: "mkshp_persons_id_upd"
  add_foreign_key "nditms", "crrs", column: "crrs_id", name: "nditm_crrs_id"
  add_foreign_key "nditms", "itms", column: "itms_id_nditm", name: "nditm_itms_id_nditm"
  add_foreign_key "nditms", "opeitms", column: "opeitms_id", name: "nditm_opeitms_id"
  add_foreign_key "nditms", "persons", column: "persons_id_upd", name: "nditm_persons_id_upd"
  add_foreign_key "nditms", "shelfnos", column: "shelfnos_id_fm", name: "nditm_shelfnos_id_fm"
  add_foreign_key "opeitms", "boxes", column: "boxes_id", name: "opeitm_boxes_id"
  add_foreign_key "opeitms", "itms", column: "itms_id", name: "opeitm_itms_id"
  add_foreign_key "opeitms", "locas", column: "locas_id_opeitm", name: "opeitm_locas_id_opeitm"
  add_foreign_key "opeitms", "persons", column: "persons_id_upd", name: "opeitm_persons_id_upd"
  add_foreign_key "opeitms", "shelfnos", column: "shelfnos_id_fm_opeitm", name: "opeitm_shelfnos_id_fm"
  add_foreign_key "opeitms", "shelfnos", column: "shelfnos_id_fm_opeitm", name: "opeitm_shelfnos_id_fm_opeitm"
  add_foreign_key "opeitms", "shelfnos", column: "shelfnos_id_to_opeitm", name: "opeitm_shelfnos_id_to"
  add_foreign_key "opeitms", "shelfnos", column: "shelfnos_id_to_opeitm", name: "opeitm_shelfnos_id_to_opeitm"
  add_foreign_key "opeitms", "units", column: "units_id_case_prdpur", name: "opeitm_units_id_case_prdpur"
  add_foreign_key "opeitms", "units", column: "units_id_case_shp", name: "opeitm_units_id_case_shp"
  add_foreign_key "outamts", "alloctbls", column: "alloctbls_id", name: "outamt_alloctbls_id"
  add_foreign_key "outamts", "crrs", column: "crrs_id", name: "outamt_crrs_id"
  add_foreign_key "outamts", "locas", column: "locas_id_out", name: "outamt_locas_id_out"
  add_foreign_key "outamts", "persons", column: "persons_id_upd", name: "outamt_persons_id_upd"
  add_foreign_key "outstks", "persons", column: "persons_id_upd", name: "outstk_persons_id_upd"
  add_foreign_key "outstks", "shelfnos", column: "shelfnos_id_out", name: "outstk_shelfnos_id_out"
  add_foreign_key "payacts", "chrgs", column: "chrgs_id", name: "payact_chrgs_id"
  add_foreign_key "payacts", "payments", column: "payments_id_pay", name: "payact_payments_id_pay"
  add_foreign_key "payacts", "persons", column: "persons_id_upd", name: "payact_persons_id_upd"
  add_foreign_key "payacts", "suppliers", column: "suppliers_id", name: "payact_suppliers_id"
  add_foreign_key "payinsts", "chrgs", column: "chrgs_id", name: "payinst_chrgs_id"
  add_foreign_key "payinsts", "payments", column: "payments_id_pay", name: "payinst_payments_id_pay"
  add_foreign_key "payinsts", "persons", column: "persons_id_upd", name: "payinst_persons_id_upd"
  add_foreign_key "payinsts", "suppliers", column: "suppliers_id", name: "payinst_suppliers_id"
  add_foreign_key "payments", "chrgs", column: "chrgs_id_payment", name: "payment_chrgs_id_payment"
  add_foreign_key "payments", "crrs", column: "crrs_id_payment", name: "payment_crrs_id_payment"
  add_foreign_key "payments", "locas", column: "locas_id_payment", name: "payment_locas_id_payment"
  add_foreign_key "payments", "persons", column: "persons_id_upd", name: "payment_persons_id_upd"
  add_foreign_key "payords", "chrgs", column: "chrgs_id", name: "payord_chrgs_id"
  add_foreign_key "payords", "crrs", column: "crrs_id_payord", name: "payord_crrs_id_payord"
  add_foreign_key "payords", "itms", column: "itms_id", name: "payord_itms_id"
  add_foreign_key "payords", "payments", column: "payments_id_pay", name: "payord_payments_id_pay"
  add_foreign_key "payords", "persons", column: "persons_id_upd", name: "payord_persons_id_upd"
  add_foreign_key "payords", "suppliers", column: "suppliers_id", name: "payord_suppliers_id"
  add_foreign_key "payschs", "chrgs", column: "chrgs_id", name: "paysch_chrgs_id"
  add_foreign_key "payschs", "itms", column: "itms_id", name: "paysch_itms_id"
  add_foreign_key "payschs", "payments", column: "payments_id_pay", name: "paysch_payments_id_pay"
  add_foreign_key "payschs", "persons", column: "persons_id_upd", name: "paysch_persons_id_upd"
  add_foreign_key "payschs", "suppliers", column: "suppliers_id", name: "paysch_suppliers_id"
  add_foreign_key "persons", "persons", column: "persons_id_upd", name: "persons_persons_id_upd"
  add_foreign_key "persons", "scrlvs", column: "scrlvs_id", name: "persons_scrlvs_id"
  add_foreign_key "persons", "sects", column: "sects_id", name: "persons_sects_id"
  add_foreign_key "persons", "usrgrps", column: "usrgrps_id", name: "persons_usrgrps_id"
  add_foreign_key "pobjects", "persons", column: "persons_id_upd", name: "pobject_persons_id_upd"
  add_foreign_key "pobjgrps", "persons", column: "persons_id_upd", name: "pobjgrp_persons_id_upd"
  add_foreign_key "pobjgrps", "pobjects", column: "pobjects_id", name: "pobjgrp_pobjects_id"
  add_foreign_key "pobjgrps", "usrgrps", column: "usrgrps_id", name: "pobjgrp_usrgrps_id"
  add_foreign_key "prdacts", "chrgs", column: "chrgs_id", name: "prdact_chrgs_id"
  add_foreign_key "prdacts", "crrs", column: "crrs_id_prdact", name: "prdact_crrs_id_prdact"
  add_foreign_key "prdacts", "opeitms", column: "opeitms_id", name: "prdact_opeitms_id"
  add_foreign_key "prdacts", "persons", column: "persons_id_upd", name: "prdact_persons_id_upd"
  add_foreign_key "prdacts", "prjnos", column: "prjnos_id", name: "prdact_prjnos_id"
  add_foreign_key "prdacts", "shelfnos", column: "shelfnos_id_fm", name: "prdact_shelfnos_id_fm"
  add_foreign_key "prdacts", "shelfnos", column: "shelfnos_id_to", name: "prdact_shelfnos_id_to"
  add_foreign_key "prdacts", "workplaces", column: "workplaces_id", name: "prdact_workplaces_id"
  add_foreign_key "prdinsts", "chrgs", column: "chrgs_id", name: "prdinst_chrgs_id"
  add_foreign_key "prdinsts", "locas", column: "locas_id_to", name: "prdinst_locas_id_to"
  add_foreign_key "prdinsts", "opeitms", column: "opeitms_id", name: "prdinst_opeitms_id"
  add_foreign_key "prdinsts", "persons", column: "persons_id_upd", name: "prdinst_persons_id_upd"
  add_foreign_key "prdinsts", "prjnos", column: "prjnos_id", name: "prdinst_prjnos_id"
  add_foreign_key "prdinsts", "shelfnos", column: "shelfnos_id_fm", name: "prdinst_shelfnos_id_fm"
  add_foreign_key "prdinsts", "shelfnos", column: "shelfnos_id_to", name: "prdinst_shelfnos_id_to"
  add_foreign_key "prdinsts", "workplaces", column: "workplaces_id", name: "prdinst_workplaces_id"
  add_foreign_key "prdords", "chrgs", column: "chrgs_id", name: "prdord_chrgs_id"
  add_foreign_key "prdords", "crrs", column: "crrs_id_prdord", name: "prdord_crrs_id_prdord"
  add_foreign_key "prdords", "opeitms", column: "opeitms_id", name: "prdord_opeitms_id"
  add_foreign_key "prdords", "persons", column: "persons_id_upd", name: "prdord_persons_id_upd"
  add_foreign_key "prdords", "prjnos", column: "prjnos_id", name: "prdord_prjnos_id"
  add_foreign_key "prdords", "shelfnos", column: "shelfnos_id_fm", name: "prdord_shelfnos_id_fm"
  add_foreign_key "prdords", "shelfnos", column: "shelfnos_id_to", name: "prdord_shelfnos_id_to"
  add_foreign_key "prdords", "workplaces", column: "workplaces_id", name: "prdord_workplaces_id"
  add_foreign_key "prdreplyinputs", "locas", column: "locas_id_to", name: "prdreplyinput_locas_id_to"
  add_foreign_key "prdreplyinputs", "opeitms", column: "opeitms_id", name: "prdreplyinput_opeitms_id"
  add_foreign_key "prdreplyinputs", "persons", column: "persons_id_upd", name: "prdreplyinput_persons_id_upd"
  add_foreign_key "prdreplyinputs", "shelfnos", column: "shelfnos_id_fm", name: "prdreplyinput_shelfnos_id_fm"
  add_foreign_key "prdrets", "chrgs", column: "chrgs_id", name: "prdret_chrgs_id"
  add_foreign_key "prdrets", "locas", column: "locas_id_fm", name: "prdret_locas_id_fm"
  add_foreign_key "prdrets", "locas", column: "locas_id_to", name: "prdret_locas_id_to"
  add_foreign_key "prdrets", "opeitms", column: "opeitms_id", name: "prdret_opeitms_id"
  add_foreign_key "prdrets", "persons", column: "persons_id_upd", name: "prdret_persons_id_upd"
  add_foreign_key "prdrets", "prjnos", column: "prjnos_id", name: "prdret_prjnos_id"
  add_foreign_key "prdrsltinputs", "opeitms", column: "opeitms_id", name: "prdrsltinput_opeitms_id"
  add_foreign_key "prdrsltinputs", "persons", column: "persons_id_upd", name: "prdrsltinput_persons_id_upd"
  add_foreign_key "prdrsltinputs", "shelfnos", column: "shelfnos_id_fm", name: "prdrsltinput_shelfnos_id_fm"
  add_foreign_key "prdschs", "chrgs", column: "chrgs_id", name: "prdsch_chrgs_id"
  add_foreign_key "prdschs", "opeitms", column: "opeitms_id", name: "prdsch_opeitms_id"
  add_foreign_key "prdschs", "persons", column: "persons_id_upd", name: "prdsch_persons_id_upd"
  add_foreign_key "prdschs", "prjnos", column: "prjnos_id", name: "prdsch_prjnos_id"
  add_foreign_key "prdschs", "shelfnos", column: "shelfnos_id_fm", name: "prdsch_shelfnos_id_fm"
  add_foreign_key "prdschs", "shelfnos", column: "shelfnos_id_to", name: "prdsch_shelfnos_id_to"
  add_foreign_key "prdschs", "workplaces", column: "workplaces_id", name: "prdsch_workplaces_id"
  add_foreign_key "pricemsts", "chrgs", column: "chrgs_id", name: "pricemst_chrgs_id"
  add_foreign_key "pricemsts", "itms", column: "itms_id", name: "pricemst_itms_id"
  add_foreign_key "pricemsts", "locas", column: "locas_id", name: "pricemst_locas_id"
  add_foreign_key "pricemsts", "persons", column: "persons_id_upd", name: "pricemst_persons_id_upd"
  add_foreign_key "prjnos", "persons", column: "persons_id_upd", name: "prjno_persons_id_upd"
  add_foreign_key "prjnos", "prjnos", column: "prjnos_id_chil", name: "prjno_prjnos_id_chil"
  add_foreign_key "prjnos", "prjnos", column: "prjnos_id_chil", name: "prjnos_id_chil"
  add_foreign_key "processcontrols", "persons", column: "persons_id_upd", name: "processcontrol_persons_id_upd"
  add_foreign_key "processreqs", "persons", column: "persons_id_upd", name: "processreq_persons_id_upd"
  add_foreign_key "puracts", "chrgs", column: "chrgs_id", name: "puract_chrgs_id"
  add_foreign_key "puracts", "crrs", column: "crrs_id_puract", name: "puract_crrs_id_puract"
  add_foreign_key "puracts", "opeitms", column: "opeitms_id", name: "puract_opeitms_id"
  add_foreign_key "puracts", "persons", column: "persons_id_upd", name: "puract_persons_id_upd"
  add_foreign_key "puracts", "prjnos", column: "prjnos_id", name: "puract_prjnos_id"
  add_foreign_key "puracts", "shelfnos", column: "shelfnos_id_fm", name: "puract_shelfnos_id_fm"
  add_foreign_key "puracts", "shelfnos", column: "shelfnos_id_to", name: "puract_shelfnos_id_to"
  add_foreign_key "puracts", "suppliers", column: "suppliers_id", name: "puract_suppliers_id"
  add_foreign_key "purdlvs", "chrgs", column: "chrgs_id", name: "purdlv_chrgs_id"
  add_foreign_key "purdlvs", "opeitms", column: "opeitms_id", name: "purdlv_opeitms_id"
  add_foreign_key "purdlvs", "persons", column: "persons_id_upd", name: "purdlv_persons_id_upd"
  add_foreign_key "purdlvs", "prjnos", column: "prjnos_id", name: "purdlv_prjnos_id"
  add_foreign_key "purdlvs", "shelfnos", column: "shelfnos_id_fm", name: "purdlv_shelfnos_id_fm"
  add_foreign_key "purdlvs", "shelfnos", column: "shelfnos_id_to", name: "purdlv_shelfnos_id_to"
  add_foreign_key "purdlvs", "suppliers", column: "suppliers_id", name: "purdlv_suppliers_id"
  add_foreign_key "purinsts", "chrgs", column: "chrgs_id", name: "purinst_chrgs_id"
  add_foreign_key "purinsts", "opeitms", column: "opeitms_id", name: "purinst_opeitms_id"
  add_foreign_key "purinsts", "persons", column: "persons_id_upd", name: "purinst_persons_id_upd"
  add_foreign_key "purinsts", "prjnos", column: "prjnos_id", name: "purinst_prjnos_id"
  add_foreign_key "purinsts", "shelfnos", column: "shelfnos_id_fm", name: "purinst_shelfnos_id_fm"
  add_foreign_key "purinsts", "shelfnos", column: "shelfnos_id_to", name: "purinst_shelfnos_id_to"
  add_foreign_key "purinsts", "suppliers", column: "suppliers_id", name: "purinst_suppliers_id"
  add_foreign_key "purords", "chrgs", column: "chrgs_id", name: "purord_chrgs_id"
  add_foreign_key "purords", "crrs", column: "crrs_id_purord", name: "purord_crrs_id_purord"
  add_foreign_key "purords", "opeitms", column: "opeitms_id", name: "purord_opeitms_id"
  add_foreign_key "purords", "persons", column: "persons_id_upd", name: "purord_persons_id_upd"
  add_foreign_key "purords", "prjnos", column: "prjnos_id", name: "purord_prjnos_id"
  add_foreign_key "purords", "shelfnos", column: "shelfnos_id_fm", name: "purord_shelfnos_id_fm"
  add_foreign_key "purords", "shelfnos", column: "shelfnos_id_to", name: "purord_shelfnos_id_to"
  add_foreign_key "purords", "suppliers", column: "suppliers_id", name: "purord_suppliers_id"
  add_foreign_key "purreplyinputs", "opeitms", column: "opeitms_id", name: "purreplyinput_opeitms_id"
  add_foreign_key "purreplyinputs", "persons", column: "persons_id_upd", name: "purreplyinput_persons_id_upd"
  add_foreign_key "purreplyinputs", "shelfnos", column: "shelfnos_id_fm", name: "purreplyinput_shelfnos_id_fm"
  add_foreign_key "purreplyinputs", "shelfnos", column: "shelfnos_id_to", name: "purreplyinput_shelfnos_id_to"
  add_foreign_key "purrets", "chrgs", column: "chrgs_id", name: "purret_chrgs_id"
  add_foreign_key "purrets", "crrs", column: "crrs_id", name: "purret_crrs_id"
  add_foreign_key "purrets", "locas", column: "locas_id_fm", name: "purret_locas_id_fm"
  add_foreign_key "purrets", "opeitms", column: "opeitms_id", name: "purret_opeitms_id"
  add_foreign_key "purrets", "persons", column: "persons_id_upd", name: "purret_persons_id_upd"
  add_foreign_key "purrets", "prjnos", column: "prjnos_id", name: "purret_prjnos_id"
  add_foreign_key "purrets", "suppliers", column: "suppliers_id", name: "purret_suppliers_id"
  add_foreign_key "purrsltinputs", "crrs", column: "crrs_id", name: "purrsltinput_crrs_id"
  add_foreign_key "purrsltinputs", "opeitms", column: "opeitms_id", name: "purrsltinput_opeitms_id"
  add_foreign_key "purrsltinputs", "persons", column: "persons_id_upd", name: "purrsltinput_persons_id_upd"
  add_foreign_key "purrsltinputs", "shelfnos", column: "shelfnos_id_fm", name: "purrsltinput_shelfnos_id_fm"
  add_foreign_key "purrsltinputs", "shelfnos", column: "shelfnos_id_to", name: "purrsltinput_shelfnos_id_to"
  add_foreign_key "purschs", "chrgs", column: "chrgs_id", name: "pursch_chrgs_id"
  add_foreign_key "purschs", "opeitms", column: "opeitms_id", name: "pursch_opeitms_id"
  add_foreign_key "purschs", "persons", column: "persons_id_upd", name: "pursch_persons_id_upd"
  add_foreign_key "purschs", "prjnos", column: "prjnos_id", name: "pursch_prjnos_id"
  add_foreign_key "purschs", "shelfnos", column: "shelfnos_id_fm", name: "pursch_shelfnos_id_fm"
  add_foreign_key "purschs", "shelfnos", column: "shelfnos_id_to", name: "pursch_shelfnos_id_to"
  add_foreign_key "purschs", "suppliers", column: "suppliers_id", name: "pursch_suppliers_id"
  add_foreign_key "reasons", "persons", column: "persons_id_upd", name: "reason_persons_id_upd"
  add_foreign_key "reports", "persons", column: "persons_id_upd", name: "report_persons_id_upd"
  add_foreign_key "reports", "usrgrps", column: "usrgrps_id", name: "report_usrgrps_id"
  add_foreign_key "rubycodings", "persons", column: "persons_id_upd", name: "rubycoding_persons_id_upd"
  add_foreign_key "rules", "persons", column: "persons_id_upd", name: "rule_persons_id_upd"
  add_foreign_key "rules", "pobjects", column: "pobjects_id", name: "rule_pobjects_id"
  add_foreign_key "schofmkords", "itms", column: "itms_id", name: "schofmkord_itms_id"
  add_foreign_key "schofmkords", "mkords", column: "mkords_id", name: "schofmkord_mkords_id"
  add_foreign_key "schofmkords", "persons", column: "persons_id_upd", name: "schofmkord_persons_id_upd"
  add_foreign_key "schofmkords", "trngantts", column: "trngantts_id", name: "schofmkord_trngantts_id"
  add_foreign_key "screenfields", "persons", column: "persons_id_upd", name: "screenfield_persons_id_upd"
  add_foreign_key "screenfields", "pobjects", column: "pobjects_id_sfd", name: "screenfield_pobjects_id_sfd"
  add_foreign_key "screenfields", "screens", column: "screens_id", name: "screenfield_screens_id"
  add_foreign_key "screenfields", "tblfields", column: "tblfields_id", name: "screenfield_tblfields_id"
  add_foreign_key "screens", "persons", column: "persons_id_upd", name: "screen_persons_id_upd"
  add_foreign_key "screens", "pobjects", column: "pobjects_id_scr", name: "screen_pobjects_id_scr"
  add_foreign_key "screens", "pobjects", column: "pobjects_id_sgrp", name: "screen_pobjects_id_sgrp"
  add_foreign_key "screens", "pobjects", column: "pobjects_id_view", name: "screen_pobjects_id_view"
  add_foreign_key "screens", "scrlvs", column: "scrlvs_id", name: "screen_scrlvs_id"
  add_foreign_key "scrlvs", "persons", column: "persons_id_upd", name: "scrlvs_persons_id_upd"
  add_foreign_key "sects", "locas", column: "locas_id_sect", name: "sect_locas_id_sect"
  add_foreign_key "sects", "locas", column: "locas_id_sect", name: "sects_locas_id_sect"
  add_foreign_key "sects", "persons", column: "persons_id_upd", name: "sect_persons_id_upd"
  add_foreign_key "shelfnos", "locas", column: "locas_id_shelfno", name: "shelfno_locas_id_shelfno"
  add_foreign_key "shelfnos", "persons", column: "persons_id_upd", name: "shelfno_persons_id_upd"
  add_foreign_key "shpacts", "chrgs", column: "chrgs_id", name: "shpact_chrgs_id"
  add_foreign_key "shpacts", "crrs", column: "crrs_id", name: "shpact_crrs_id"
  add_foreign_key "shpacts", "itms", column: "itms_id", name: "shpact_itms_id"
  add_foreign_key "shpacts", "persons", column: "persons_id_upd", name: "shpact_persons_id_upd"
  add_foreign_key "shpacts", "prjnos", column: "prjnos_id", name: "shpact_prjnos_id"
  add_foreign_key "shpacts", "shelfnos", column: "shelfnos_id_to", name: "shpact_shelfnos_id_to"
  add_foreign_key "shpacts", "transports", column: "transports_id", name: "shpact_transports_id"
  add_foreign_key "shpacts", "units", column: "units_id_case_shp", name: "shpact_units_id_case_shp"
  add_foreign_key "shpinsts", "chrgs", column: "chrgs_id", name: "shpinst_chrgs_id"
  add_foreign_key "shpinsts", "itms", column: "itms_id", name: "shpinst_itms_id"
  add_foreign_key "shpinsts", "locas", column: "locas_id_to", name: "shpinst_locas_id_to"
  add_foreign_key "shpinsts", "persons", column: "persons_id_upd", name: "shpinst_persons_id_upd"
  add_foreign_key "shpinsts", "prjnos", column: "prjnos_id", name: "shpinst_prjnos_id"
  add_foreign_key "shpinsts", "shelfnos", column: "shelfnos_id_fm", name: "shpinst_shelfnos_id_fm"
  add_foreign_key "shpinsts", "shelfnos", column: "shelfnos_id_to", name: "shpinst_shelfnos_id_to"
  add_foreign_key "shpinsts", "transports", column: "transports_id", name: "shpinst_transports_id"
  add_foreign_key "shpinsts", "units", column: "units_id_case_shp", name: "shpinst_units_id_case_shp"
  add_foreign_key "shpords", "chrgs", column: "chrgs_id", name: "shpord_chrgs_id"
  add_foreign_key "shpords", "crrs", column: "crrs_id_shpord", name: "shpord_crrs_id_shpord"
  add_foreign_key "shpords", "itms", column: "itms_id", name: "shpord_itms_id"
  add_foreign_key "shpords", "locas", column: "locas_id_to", name: "shpord_locas_id_to"
  add_foreign_key "shpords", "persons", column: "persons_id_upd", name: "shpord_persons_id_upd"
  add_foreign_key "shpords", "prjnos", column: "prjnos_id", name: "shpord_prjnos_id"
  add_foreign_key "shpords", "shelfnos", column: "shelfnos_id_fm", name: "shpord_shelfnos_id_fm"
  add_foreign_key "shpords", "shelfnos", column: "shelfnos_id_to", name: "shpord_shelfnos_id_to"
  add_foreign_key "shpords", "transports", column: "transports_id", name: "shpord_transports_id"
  add_foreign_key "shprets", "chrgs", column: "chrgs_id", name: "shpret_chrgs_id"
  add_foreign_key "shprets", "crrs", column: "crrs_id", name: "shpret_crrs_id"
  add_foreign_key "shprets", "itms", column: "itms_id", name: "shpret_itms_id"
  add_foreign_key "shprets", "persons", column: "persons_id_upd", name: "shpret_persons_id_upd"
  add_foreign_key "shprets", "prjnos", column: "prjnos_id", name: "shpret_prjnos_id"
  add_foreign_key "shprets", "shelfnos", column: "shelfnos_id_fm", name: "shpret_shelfnos_id_fm"
  add_foreign_key "shprets", "shelfnos", column: "shelfnos_id_to", name: "shpret_shelfnos_id_to"
  add_foreign_key "shpschs", "chrgs", column: "chrgs_id", name: "shpsch_chrgs_id"
  add_foreign_key "shpschs", "itms", column: "itms_id", name: "shpsch_itms_id"
  add_foreign_key "shpschs", "locas", column: "locas_id_to", name: "shpsch_locas_id_to"
  add_foreign_key "shpschs", "persons", column: "persons_id_upd", name: "shpsch_persons_id_upd"
  add_foreign_key "shpschs", "prjnos", column: "prjnos_id", name: "shpsch_prjnos_id"
  add_foreign_key "shpschs", "shelfnos", column: "shelfnos_id_fm", name: "shpsch_shelfnos_id_fm"
  add_foreign_key "shpschs", "shelfnos", column: "shelfnos_id_to", name: "shpsch_shelfnos_id_to"
  add_foreign_key "shpschs", "transports", column: "transports_id", name: "shpsch_transports_id"
  add_foreign_key "srctbls", "persons", column: "persons_id_upd", name: "srctbl_persons_id_upd"
  add_foreign_key "suppliers", "chrgs", column: "chrgs_id_supplier", name: "supplier_chrgs_id_supplier"
  add_foreign_key "suppliers", "crrs", column: "crrs_id_supplier", name: "supplier_crrs_id_supplier"
  add_foreign_key "suppliers", "locas", column: "locas_id_supplier", name: "supplier_locas_id_supplier"
  add_foreign_key "suppliers", "payments", column: "payments_id", name: "supplier_payments_id"
  add_foreign_key "suppliers", "persons", column: "persons_id_upd", name: "supplier_persons_id_upd"
  add_foreign_key "supplierwhs", "itms", column: "itms_id", name: "supplierwh_itms_id"
  add_foreign_key "supplierwhs", "persons", column: "persons_id_upd", name: "supplierwh_persons_id_upd"
  add_foreign_key "supplierwhs", "suppliers", column: "suppliers_id", name: "supplierwh_suppliers_id"
  add_foreign_key "tblfields", "blktbs", column: "blktbs_id", name: "tblfield_blktbs_id"
  add_foreign_key "tblfields", "fieldcodes", column: "fieldcodes_id", name: "tblfield_fieldcodes_id"
  add_foreign_key "tblfields", "persons", column: "persons_id_upd", name: "tblfield_persons_id_upd"
  add_foreign_key "tblinkflds", "persons", column: "persons_id_upd", name: "tblinkfld_persons_id_upd"
  add_foreign_key "tblinkflds", "tblfields", column: "tblfields_id", name: "tblinkfld_tblfields_id"
  add_foreign_key "tblinkflds", "tblinks", column: "tblinks_id", name: "tblinkfld_tblinks_id"
  add_foreign_key "tblinks", "blktbs", column: "blktbs_id_dest", name: "tblink_blktbs_id_dest"
  add_foreign_key "tblinks", "persons", column: "persons_id_upd", name: "tblink_persons_id_upd"
  add_foreign_key "transports", "persons", column: "persons_id_upd", name: "transport_persons_id_upd"
  add_foreign_key "trngantts", "chrgs", column: "chrgs_id_org", name: "trngantt_chrgs_id_org"
  add_foreign_key "trngantts", "chrgs", column: "chrgs_id_pare", name: "trngantt_chrgs_id_pare"
  add_foreign_key "trngantts", "chrgs", column: "chrgs_id_trn", name: "trngantt_chrgs_id_trn"
  add_foreign_key "trngantts", "itms", column: "itms_id_org", name: "trngantt_itms_id_org"
  add_foreign_key "trngantts", "itms", column: "itms_id_pare", name: "trngantt_itms_id_pare"
  add_foreign_key "trngantts", "itms", column: "itms_id_trn", name: "trngantt_itms_id_trn"
  add_foreign_key "trngantts", "locas", column: "locas_id_org", name: "trngantt_locas_id_org"
  add_foreign_key "trngantts", "locas", column: "locas_id_pare", name: "trngantt_locas_id_pare"
  add_foreign_key "trngantts", "locas", column: "locas_id_trn", name: "trngantt_locas_id_trn"
  add_foreign_key "trngantts", "mkords", column: "mkords_id_trngantt", name: "trngantt_mkords_id_trngantt"
  add_foreign_key "trngantts", "persons", column: "persons_id_upd", name: "trngantt_persons_id_upd"
  add_foreign_key "trngantts", "prjnos", column: "prjnos_id", name: "trngantt_prjnos_id"
  add_foreign_key "trngantts", "shelfnos", column: "shelfnos_id_to", name: "trngantt_shelfnos_id_to"
  add_foreign_key "units", "persons", column: "persons_id_upd", name: "unit_persons_id_upd"
  add_foreign_key "usebuttons", "buttons", column: "buttons_id", name: "usebutton_buttons_id"
  add_foreign_key "usebuttons", "persons", column: "persons_id_upd", name: "usebutton_persons_id_upd"
  add_foreign_key "usebuttons", "screens", column: "screens_id_ub", name: "usebutton_screens_id_ub"
  add_foreign_key "userprocs", "persons", column: "persons_id_upd", name: "userprocs_persons_id_upd"
  add_foreign_key "workplaces", "chrgs", column: "chrgs_id_workplace", name: "workplace_chrgs_id_workplace"
  add_foreign_key "workplaces", "locas", column: "locas_id_workplace", name: "workplace_locas_id_workplace"
  add_foreign_key "workplaces", "persons", column: "persons_id_upd", name: "workplace_persons_id_upd"
end
