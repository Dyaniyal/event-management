class AddUpdateCountToInviteeDatum < ActiveRecord::Migration
  def change
  	add_column :invitee_data, :telecaller_update_count, :string
  	add_column :invitee_data, :registration_update_count, :string
  end
end
