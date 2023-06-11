class AddHideThisPanelToPanels < ActiveRecord::Migration
  def change
  	add_column :panels, :hide_panel, :string, :default => "deactive"
  end
end
