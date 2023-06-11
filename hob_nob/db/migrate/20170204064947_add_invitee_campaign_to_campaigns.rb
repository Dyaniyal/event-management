class AddInviteeCampaignToCampaigns < ActiveRecord::Migration
  def change
  	add_column :campaigns, :invitee_campaign, :string
  	add_column :campaigns, :total_mails_sent, :string
  end
end
