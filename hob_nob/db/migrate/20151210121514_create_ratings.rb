class CreateRatings < ActiveRecord::Migration
  def change
    create_table :ratings do |t|
    	t.integer :ratable_id
    	t.string :ratable_type
    	t.float :rating
    	t.integer :out_of
    	t.text :comments
    	t.integer :rated_by


      t.timestamps null: false
    end
  end
end
