class AddTitleToAgendas < ActiveRecord::Migration
  def change
  	add_column :agendas, :title, :string
  end
end
