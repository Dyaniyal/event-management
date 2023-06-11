class AddAnonymousQnas < ActiveRecord::Migration
  def change
  	add_column :qnas, :anonymous_on_wall, :string, :default => "false"
  end
end
