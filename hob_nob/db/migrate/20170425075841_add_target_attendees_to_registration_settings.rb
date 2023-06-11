class AddTargetAttendeesToRegistrationSettings < ActiveRecord::Migration
  def change
    add_column :registration_settings, :target_attendees, :integer
  end
end
