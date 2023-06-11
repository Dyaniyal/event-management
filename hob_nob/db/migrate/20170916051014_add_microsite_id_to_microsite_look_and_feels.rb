class AddMicrositeIdToMicrositeLookAndFeels < ActiveRecord::Migration
  def change
    add_column :microsite_look_and_feels, :microsite_id, :integer
  end
end
