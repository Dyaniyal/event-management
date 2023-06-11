class AddColumnIntroductionToContact < ActiveRecord::Migration
  def change
  	add_column :contacts, :introduction, :text
  end
end
