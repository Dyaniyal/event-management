class AddAgreementStatusToInvitees < ActiveRecord::Migration
  def change
  	add_column :invitees, :agree_to_disclaimer_text, :string
  end
end
