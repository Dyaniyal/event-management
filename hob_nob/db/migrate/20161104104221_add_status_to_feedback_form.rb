class AddStatusToFeedbackForm < ActiveRecord::Migration
  def change
    add_column :feedback_forms, :status, :string, :default => "active"
  end
end
