class CreateIconLibraries < ActiveRecord::Migration
  def change
    create_table :icon_libraries do |t|
      t.integer :licensee_id
      t.string :icon_library_name
      t.timestamps null: false
    end
  end
end
