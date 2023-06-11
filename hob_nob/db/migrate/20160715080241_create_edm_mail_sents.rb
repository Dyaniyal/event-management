class CreateEdmMailSents < ActiveRecord::Migration
  def change
    create_table :edm_mail_sents do |t|
    	t.integer  "event_id"
      t.integer  "edm_id"
      t.string   "email"
      t.string   "open", default: "no"
      t.string   "status", default: "sent"

      t.timestamps null: false
    end
  end
end
