class AddSequenceToPanels < ActiveRecord::Migration
  def change
    add_column :panels, :sequence, :integer
  end
end
