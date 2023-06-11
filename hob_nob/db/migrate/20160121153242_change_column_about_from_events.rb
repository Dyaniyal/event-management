class ChangeColumnAboutFromEvents < ActiveRecord::Migration
  def change
  	change_column :events, :about, :text
  end
end
