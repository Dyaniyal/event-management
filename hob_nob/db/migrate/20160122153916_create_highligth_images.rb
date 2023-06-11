class CreateHighligthImages < ActiveRecord::Migration
  def change
    create_table :highligth_images do |t|
      t.string  :name
      t.timestamps null: false
    end
  end
end
