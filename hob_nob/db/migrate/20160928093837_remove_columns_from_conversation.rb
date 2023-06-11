class RemoveColumnsFromConversation < ActiveRecord::Migration
  def change
  	remove_column :conversations, :last_name_user
  	remove_column :conversations, :first_name_user
  	remove_column :conversations, :profile_pic_url_user
  end
end
