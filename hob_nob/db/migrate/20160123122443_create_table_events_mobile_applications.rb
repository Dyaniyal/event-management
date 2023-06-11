class CreateTableEventsMobileApplications < ActiveRecord::Migration
  def change
    create_table :events_mobile_applications do |t|
    	t.integer :event_id
   		t.integer :mobile_application_id
   		t.timestamps null: false
    end
  end
end
