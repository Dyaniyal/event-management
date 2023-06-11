class AddWayFinderToAgenda < ActiveRecord::Migration
  def change
    add_column :agendas, :way_finder, :string,  :default => 'no'
  end
end
