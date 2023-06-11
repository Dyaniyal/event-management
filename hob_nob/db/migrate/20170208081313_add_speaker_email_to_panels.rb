class AddSpeakerEmailToPanels < ActiveRecord::Migration
  def change
  	add_column :panels, :speaker_email, :string
  end
end
