class AddSponsorIdToPolls < ActiveRecord::Migration
  def change
    add_column :polls, :sponsor_id, :integer
  end
end
