class AddVisitorRegistrationToInvitees < ActiveRecord::Migration
  def change
  	add_column :invitees, :visitor_registration, :string
  end
end
