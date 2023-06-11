class AddFieldsToManageInviteeFields < ActiveRecord::Migration
	def change
		add_column :manage_invitee_fields, :first_name, :string, default: "true"
		add_column :manage_invitee_fields, :last_name, :string, default: "true"
		remove_column :manage_invitee_fields, :name_of_the_invitee
	end
end
