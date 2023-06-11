class AddCallbackDatetimeAndTelecallerIdToInviteeDatums < ActiveRecord::Migration
  def change
  	add_column :invitee_data, :attr19, :string
  	add_column :invitee_data, :attr20, :string
  	add_column :invitee_data, :callback_datetime, :datetime
  	add_column :invitee_data, :telecaller_id, :integer
  end
end
