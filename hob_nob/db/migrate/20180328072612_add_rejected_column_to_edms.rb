class AddRejectedColumnToEdms < ActiveRecord::Migration
  def change
  	add_column :edms, :rejected_domain, :string
  end
end
