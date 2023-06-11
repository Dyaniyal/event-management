class AddColumnContactPersonNameToExhibitors < ActiveRecord::Migration
  def change
    add_column :exhibitors, :contact_person_name, :string
  end
end
