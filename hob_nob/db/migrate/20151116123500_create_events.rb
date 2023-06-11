class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
    	t.string    :client_name
    	t.string    :business_unit
    	t.string    :event_code
    	t.string    :event_name
    	t.string    :event_type
    	t.boolean   :multi_city
    	t.string    :cities
    	t.datetime  :start_event_date
        t.datetime  :end_event_date
        t.datetime  :start_event_time
        t.datetime  :end_event_time
    	t.string    :venues
    	t.string    :pax
    	t.string    :event_admin_field
    	t.string    :event_manager_field
    	t.string    :event_executive_field
        t.integer   :client_id
    	
      t.timestamps null: false
    end
  end
end
