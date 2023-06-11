class CreateEdms < ActiveRecord::Migration
  def change
    create_table :edms do |t|
      t.integer  "campaign_id"
      t.string   "subject_line"
      t.datetime "edm_broadcast_time"
      t.string   "template_type"
      t.text     "custom_code"
      t.string   "default_template"
      t.string   "edm_broadcast_value"
      t.attachment "header_image"
      t.attachment "footer_image"
      t.text      "body"
      t.string    "flag",:default => "0"
      t.timestamps null: false
    end
  end
end
