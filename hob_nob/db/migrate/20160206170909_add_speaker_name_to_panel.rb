class AddSpeakerNameToPanel < ActiveRecord::Migration
  def change
  	add_column :panels, :speaker_name, :string
  end
end
