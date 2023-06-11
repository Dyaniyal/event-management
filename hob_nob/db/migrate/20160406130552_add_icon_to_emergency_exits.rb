class AddIconToEmergencyExits < ActiveRecord::Migration
  def change
    add_column :emergency_exits, :icon_file_name, :string
	add_column :emergency_exits, :icon_content_type, :string
	add_column :emergency_exits, :icon_file_size, :integer
	add_column :emergency_exits, :icon_updated_at, :datetime
  end
end
