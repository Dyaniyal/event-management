class AddEventIdToRegistrationSettings < ActiveRecord::Migration
  def change
    add_column :registration_settings, :event_id, :integer
  end
end
