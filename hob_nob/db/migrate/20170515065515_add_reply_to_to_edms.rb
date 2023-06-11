class AddReplyToToEdms < ActiveRecord::Migration
  def change
  	add_column :edms, :reply_to_email, :string
  end
end
