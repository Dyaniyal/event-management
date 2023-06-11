class AddApplicationStstusToInvitees < ActiveRecord::Migration
  def change
    add_column :invitees, :application_status, :string
  end
end
