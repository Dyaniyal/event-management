class AddFieldsToSponsors < ActiveRecord::Migration
  def change
    add_column :sponsors, :name, :string
    add_column :sponsors, :email, :string
    add_column :sponsors, :description, :text
  end
end
