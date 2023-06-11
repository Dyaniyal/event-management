class AddUnsubscribeTrueOrFalseToEdms < ActiveRecord::Migration
  def change
  	add_column :edms, :opt_for_unsubscribe, :boolean, :default => false
  end
end
