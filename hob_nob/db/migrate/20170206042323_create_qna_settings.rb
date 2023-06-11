class CreateQnaSettings < ActiveRecord::Migration
  def change
    create_table :qna_settings do |t|
      t.integer :event_id
      t.string :display_qna_on_app
      t.timestamps null: false
    end
  end
end
