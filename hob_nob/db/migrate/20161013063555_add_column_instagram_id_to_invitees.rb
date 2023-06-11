class AddColumnInstagramIdToInvitees < ActiveRecord::Migration
  def change
    add_column :invitees, :instagram_id, :string
  end
end
