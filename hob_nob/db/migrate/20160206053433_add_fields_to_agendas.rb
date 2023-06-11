class AddFieldsToAgendas < ActiveRecord::Migration
  def change
    add_column :agendas, :start_agenda_date, :datetime
    add_column :agendas, :end_agenda_date, :datetime
  end
end
