class AddAgendaIdToEKits < ActiveRecord::Migration
  def change
    add_column :e_kits, :agenda_id, :integer
  end
end
