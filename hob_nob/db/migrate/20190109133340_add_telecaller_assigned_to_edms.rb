class AddTelecallerAssignedToEdms < ActiveRecord::Migration
  def change
    add_column :edms, :telecaller_assigned, :boolean, { default: false }
  end
end
