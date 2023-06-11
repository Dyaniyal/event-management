class AddColumnsToInviteeDatums < ActiveRecord::Migration
  def change
  	#add_column :invitee_data, :call_status, :string
  	add_column :invitee_data, :reported_status, :string
  	add_column :invitee_data, :invitee_data_updated, :datetime
  end
end
