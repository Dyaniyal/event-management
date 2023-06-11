class CreateDayoptions < ActiveRecord::Migration
  def change
    create_table :dayoptions do |t|
    	t.string :daytype

      t.timestamps null: false
    end
  end
end
