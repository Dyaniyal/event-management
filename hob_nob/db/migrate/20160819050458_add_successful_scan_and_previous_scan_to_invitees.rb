class AddSuccessfulScanAndPreviousScanToInvitees < ActiveRecord::Migration
  def change
    add_column :invitees, :previous_scan, :boolean, :default => false
    add_column :invitees, :successful_scan, :boolean, :default => false
  end
end
