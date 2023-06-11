class AddEventTypeForRegistrationToEvents < ActiveRecord::Migration
  def change
    add_column :events, :event_type_for_registration, :string
  end
end
