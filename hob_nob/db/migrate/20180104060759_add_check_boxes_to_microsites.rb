class AddCheckBoxesToMicrosites < ActiveRecord::Migration
  def change
  	add_column :microsite_look_and_feels, :home_page_content, :string
  	add_column :microsite_look_and_feels, :event_dates, :string
  	add_column :microsite_look_and_feels, :event_location, :string
  	add_column :microsite_look_and_feels, :contact_detail, :string
  	add_column :microsite_look_and_feels, :event_venue, :string
  end
end
