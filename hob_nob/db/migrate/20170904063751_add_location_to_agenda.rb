class AddLocationToAgenda < ActiveRecord::Migration
  def change
    add_column :agendas, :location, :text
  end
end
