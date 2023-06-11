class AddColumnActiveToEdmsTable < ActiveRecord::Migration

  def change
    add_column :edms, :active, :boolean, default: true
  end

end
