class CreateLicensees < ActiveRecord::Migration
  def change
    create_table :licensees do |t|
      t.string :name
      t.string :email
      t.string :company
      t.string :status
      t.date :licence_start_date
      t.date :licence_end_date

      t.timestamps null: false
    end
  end
end
