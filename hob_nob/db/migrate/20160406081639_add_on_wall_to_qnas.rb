class AddOnWallToQnas < ActiveRecord::Migration
  def change
    add_column :qnas, :on_wall, :string
  end
end
