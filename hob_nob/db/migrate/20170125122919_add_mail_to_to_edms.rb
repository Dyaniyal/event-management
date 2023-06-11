class AddMailToToEdms < ActiveRecord::Migration
  def change
  	add_column :edms, :mail_to, :string
  end
end
