class AddFirstNameLastNameColumnToInviteeAndSpeaker < ActiveRecord::Migration
  def change
  	add_column :invitees, :first_name, :string
  	add_column :invitees, :last_name, :string

  	add_column :speakers, :first_name, :string
  	add_column :speakers, :last_name, :string
  end
end
