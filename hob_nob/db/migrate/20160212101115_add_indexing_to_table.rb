class AddIndexingToTable < ActiveRecord::Migration
  def change
  	add_index :mobile_applications, [:name], :name => "index_name_on_mobile_applications"
  	
  	add_index :polls, [:status], :name => "index_status_on_polls"
  	add_index :polls, [:sequence], :name => "index_sequence_on_polls"

  	add_index :qnas, [:status], :name => "index_status_on_qnas"

  	add_index :speakers, [:speaker_name], :name => "index_speaker_name_on_speakers"
  	add_index :speakers, [:email_address], :name => "index_email_address_on_speakers"
  	add_index :speakers, [:designation], :name => "index_designation_on_speakers"
  	add_index :speakers, [:sequence], :name => "index_sequence_on_speakers"

  	add_index :sponsors, [:sponsor_type], :name => "index_sponsor_type_on_sponsors"

  	add_index :users, [:first_name], :name => "index_first_name_on_users"
  	add_index :users, [:package_type], :name => "index_package_type_on_users"
  	
  	add_index :winners, [:name], :name => "index_name_on_winners"
  end
end
