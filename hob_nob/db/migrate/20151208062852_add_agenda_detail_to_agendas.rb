class AddAgendaDetailToAgendas < ActiveRecord::Migration
  def change
  	add_column :agendas, :agenda_date, :datetime
  	add_column :agendas, :start_agenda_time, :datetime
  	add_column :agendas, :end_agenda_time, :datetime
  end
end
