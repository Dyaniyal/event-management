class AddIndexingToInvitees < ActiveRecord::Migration
  def change
  	add_index :invitees, [:name_of_the_invitee], :name => "index_name_of_the_invitee_on_invitees"
  end
end
