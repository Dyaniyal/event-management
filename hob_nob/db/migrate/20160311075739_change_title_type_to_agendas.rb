class ChangeTitleTypeToAgendas < ActiveRecord::Migration
  def change
  	change_column :agendas, :title, :text
  end
end
