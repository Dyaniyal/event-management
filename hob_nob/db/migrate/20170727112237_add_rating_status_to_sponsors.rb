class AddRatingStatusToSponsors < ActiveRecord::Migration
  def change
    add_column :sponsors, :rating_status, :string
  end
end
