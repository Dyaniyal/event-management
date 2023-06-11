class AddColumnContactPersonNameToSponsors < ActiveRecord::Migration
  def change
    add_column :sponsors, :contact_person_name, :string
  end
end
