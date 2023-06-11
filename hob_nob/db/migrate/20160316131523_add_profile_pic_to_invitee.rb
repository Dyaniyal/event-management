class AddProfilePicToInvitee < ActiveRecord::Migration
  def change
  	add_attachment :invitees, :profile_pic
  	add_column :invitees, :about, :text
  	add_column :invitees, :interested_topics, :string
  end
end
