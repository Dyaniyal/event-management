class AddUserAnsweredToQnas < ActiveRecord::Migration
  def change
  	add_column :qnas, :user_answered, :string, :default => "no"
  end
end
