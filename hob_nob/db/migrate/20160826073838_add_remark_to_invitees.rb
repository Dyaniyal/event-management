class AddRemarkToInvitees < ActiveRecord::Migration
  def change
  	add_column :invitees, :remark, :text
  end
end
