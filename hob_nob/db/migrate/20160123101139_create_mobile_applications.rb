class CreateMobileApplications < ActiveRecord::Migration
  def change
    create_table :mobile_applications do |t|
    t.string :name
    t.string :application_type
    t.integer :client_id
    

      t.timestamps null: false
    end
  end
end
