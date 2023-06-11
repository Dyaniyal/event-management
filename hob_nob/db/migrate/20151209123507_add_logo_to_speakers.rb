class AddLogoToSpeakers < ActiveRecord::Migration
  def change
  	add_attachment :speakers, :profile_pic
  end
end
