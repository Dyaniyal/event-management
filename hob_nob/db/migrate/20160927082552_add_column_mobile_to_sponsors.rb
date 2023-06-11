class AddColumnMobileToSponsors < ActiveRecord::Migration
  def change
    add_column :sponsors, :mobile, :string
  end
end
