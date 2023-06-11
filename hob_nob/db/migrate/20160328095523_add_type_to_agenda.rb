class AddTypeToAgenda < ActiveRecord::Migration
  def change
  	add_column :agendas, :agenda_type , :string
  end
end
