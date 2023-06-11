class CreateWinners < ActiveRecord::Migration
  def change
    create_table :winners do |t|
    t.integer  :award_id
    t.string    :name	
    t.timestamps null: false
    end
  end
end
