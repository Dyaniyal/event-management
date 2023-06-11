class AddOnsiteRegistrationToInvitees < ActiveRecord::Migration
  def change
    add_column :invitees, :onsite_registration, :boolean
  end
end
