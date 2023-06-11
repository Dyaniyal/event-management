class AddSentToEdms < ActiveRecord::Migration
  def change
    add_column :edms, :sent, :string
  end
end
