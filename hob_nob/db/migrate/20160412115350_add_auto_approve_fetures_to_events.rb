class AddAutoApproveFeturesToEvents < ActiveRecord::Migration
  def change
    add_column :events, :conversation_auto_approve, :string, default: "false"
    add_column :events, :qna_auto_approve, :string, default: "false"
    add_column :events, :poll_auto_approve, :string, default: "true"
  end
end
