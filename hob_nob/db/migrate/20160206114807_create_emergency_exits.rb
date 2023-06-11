class CreateEmergencyExits < ActiveRecord::Migration
  def change
    create_table :emergency_exits do |t|
    	t.string  :event_name
    	t.integer :event_id
    	t.string 	:title
    	t.string   :emergency_exit_file_name, limit: 255
    	t.string   :emergency_exit_content_type, limit: 255
    	t.integer  :emergency_exit_file_size, limit: 4
    	t.datetime :emergency_exit_updated_at
      t.timestamps null: false
    end
  end
end
