class AddColumnToInviteeDatum < ActiveRecord::Migration
  def change
  	add_column :invitee_data, :registration_status, :string
  end
end
