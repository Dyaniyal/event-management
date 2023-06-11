class AddResponseColumnsToInviteeNotifications < ActiveRecord::Migration
  def change
  	add_column :invitee_notifications, :ios_push_response, :text
  	add_column :invitee_notifications, :android_push_response, :text
  end
end
