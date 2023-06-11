class AddRatingFirstTextToPolls < ActiveRecord::Migration
  def change
    add_column :polls, :rating_first_text, :string
  end
end
