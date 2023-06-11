class AddSenderNameToEdms < ActiveRecord::Migration
  def change
  	add_column :edms, :sender_name, :string
  end
end
