class AddAttr19Attr20InInviteeStructures < ActiveRecord::Migration
  def change
  	add_column :invitee_structures, :attr19, :string
  	add_column :invitee_structures, :attr20, :string
  end
end
