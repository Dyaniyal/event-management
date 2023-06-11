class AddColumnsInConversations < ActiveRecord::Migration
  def change
  	add_column :conversations, :first_name_user, :string
  	add_column :conversations, :last_name_user, :string  	
  	add_column :conversations, :profile_pic_url_user, :string
  end
end
