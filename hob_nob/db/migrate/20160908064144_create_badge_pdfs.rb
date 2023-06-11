class CreateBadgePdfs < ActiveRecord::Migration
  def change
    create_table :badge_pdfs do |t|
      t.integer :event_id
      t.string :column1
      t.string :column2
      t.string :column3

      t.timestamps null: false
    end
  end
end
