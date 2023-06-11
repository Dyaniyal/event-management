class ChangeTextInClients < ActiveRecord::Migration
  def change
  	change_column :clients, :remarks, :text
  end
end
