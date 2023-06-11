class CreateInviteeData < ActiveRecord::Migration
  def change
    create_table :invitee_data do |t|
      t.integer :invitee_structure_id
      t.string :attr1
      t.string :attr2
      t.string :attr3
      t.string :attr4
      t.string :attr5
      t.string :attr6
      t.string :attr7
      t.string :attr8
      t.string :attr9
      t.string :attr10
      t.string :attr11
      t.string :attr12
      t.string :attr13
      t.string :attr14
      t.string :attr15
      t.string :attr16
      t.string :attr17
      t.string :attr18
      t.string :status

      t.timestamps null: false
    end
  end
end
