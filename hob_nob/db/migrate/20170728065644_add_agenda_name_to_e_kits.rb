class AddAgendaNameToEKits < ActiveRecord::Migration
  def change
  	add_column :e_kits, :sponsor_id, :integer
  end
end
