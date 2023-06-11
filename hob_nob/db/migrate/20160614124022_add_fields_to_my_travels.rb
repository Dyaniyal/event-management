class AddFieldsToMyTravels < ActiveRecord::Migration
  def change
  	add_column :my_travels, :attach_file_1_name, :string

  	add_attachment :my_travels, :attach_file_2
  	add_column :my_travels, :attach_file_2_name, :string

  	add_attachment :my_travels, :attach_file_3
  	add_column :my_travels, :attach_file_3_name, :string

  	add_attachment :my_travels, :attach_file_4
  	add_column :my_travels, :attach_file_4_name, :string

  	add_attachment :my_travels, :attach_file_5
  	add_column :my_travels, :attach_file_5_name, :string
  end
end
