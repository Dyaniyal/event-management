class AddSessionToAgenda < ActiveRecord::Migration
  def change
    add_column :event_features, :session_to_agenda, :string, :default => "no"
  end
end
