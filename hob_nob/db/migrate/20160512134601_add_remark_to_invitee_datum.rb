class AddRemarkToInviteeDatum < ActiveRecord::Migration
  def change
    add_column :invitee_data, :remark, :string
  end
end
