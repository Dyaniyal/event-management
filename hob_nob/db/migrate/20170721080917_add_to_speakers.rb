class AddToSpeakers < ActiveRecord::Migration
  def change
  	add_column :speakers, :show_speaker_feature, :string
    add_column :speakers, :group_ids, :text
  end
end
