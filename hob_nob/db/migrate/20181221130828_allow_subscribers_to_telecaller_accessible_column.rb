class AllowSubscribersToTelecallerAccessibleColumn < ActiveRecord::Migration
  def change
    add_column :telecaller_accessible_columns, :allow_unsubscribers, :boolean, {default:false}
  end
end
