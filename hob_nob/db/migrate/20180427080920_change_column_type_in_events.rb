class ChangeColumnTypeInEvents < ActiveRecord::Migration
  def change
  	change_column :events, :microsite_map, :text
  end
end
