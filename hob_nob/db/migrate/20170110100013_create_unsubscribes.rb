class CreateUnsubscribes < ActiveRecord::Migration
  def change
    create_table :unsubscribes do |t|
      t.integer  "event_id"
      t.integer  "edm_id"
      t.string   "email"
      t.string   "unsubscribe", default: "false"

      t.timestamps null: false
    end
  end
end
