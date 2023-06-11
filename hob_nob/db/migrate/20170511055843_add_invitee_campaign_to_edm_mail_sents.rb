class AddInviteeCampaignToEdmMailSents < ActiveRecord::Migration
  def change
    add_column :edm_mail_sents, :invitee_campaign, :boolean, :default => false
  end
end
