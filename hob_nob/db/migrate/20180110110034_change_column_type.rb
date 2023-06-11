class ChangeColumnType < ActiveRecord::Migration
  def change
  	change_column :telecaller_groups, :assign_grouping, :text
  end
end
