class AddAttachFileToMyTravels < ActiveRecord::Migration
  def change
  	add_attachment :my_travels, :attach_file
  end
end
