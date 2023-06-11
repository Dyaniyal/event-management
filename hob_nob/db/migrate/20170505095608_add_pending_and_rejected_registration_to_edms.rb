class AddPendingAndRejectedRegistrationToEdms < ActiveRecord::Migration
  def change
  	add_column :edms, :registration_pending, :string
  	add_column :edms, :registration_rejected, :string
  end
end
