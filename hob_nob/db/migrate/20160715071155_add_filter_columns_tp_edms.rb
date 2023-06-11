class AddFilterColumnsTpEdms < ActiveRecord::Migration
  def change
  	add_column :edms, :email_sent, :string
    add_column :edms, :registered, :string
    add_column :edms, :registration_approved, :string
    add_column :edms, :confirmed, :string
    add_column :edms, :attended, :string
    add_column :edms, :email_opened, :string
  end
end
