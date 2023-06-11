class Addfieldsininviteedatums < ActiveRecord::Migration
  def change
  	add_column :invitee_data, :call_attempt, :integer, :default => 1
  end
end
