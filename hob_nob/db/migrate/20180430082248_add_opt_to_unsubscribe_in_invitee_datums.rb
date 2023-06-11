class AddOptToUnsubscribeInInviteeDatums < ActiveRecord::Migration
  def change
  	add_column :invitee_data, :opt_unsubscribe, :boolean, :default => false
  end
end
