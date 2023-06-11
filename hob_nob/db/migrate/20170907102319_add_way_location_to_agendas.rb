class AddWayLocationToAgendas < ActiveRecord::Migration
  def change
    add_column :agendas, :way_location, :text
  end
end
