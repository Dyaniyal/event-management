class AddColumnToAgendas < ActiveRecord::Migration
  def change
  	add_column :agendas, :sequence, :integer
  	add_column :agendas, :last_force_destroyed, :integer
  end
end
