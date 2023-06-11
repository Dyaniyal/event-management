class AddColumnsToEdms < ActiveRecord::Migration
  def change
  	add_column :edms, :cc, :text
  	add_column :edms, :bcc, :text
  end
end
