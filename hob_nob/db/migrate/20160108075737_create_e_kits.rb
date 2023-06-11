class CreateEKits < ActiveRecord::Migration
  def change
    create_table :e_kits do |t|
      t.belongs_to :event
      t.string :name
      t.string :tag_name

      t.timestamps null: false
    end
    add_attachment :e_kits, :attachment
  end
end
