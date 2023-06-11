class AddColumnFacebookIdGoogleIdLinkedinIdInInvitees < ActiveRecord::Migration
  def change
  	add_column :invitees, :google_id, :text
  	add_column :invitees, :linkedin_id, :text
  	add_column :invitees, :provider, :string
  end
end
