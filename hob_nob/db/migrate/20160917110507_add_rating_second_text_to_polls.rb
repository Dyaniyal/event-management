class AddRatingSecondTextToPolls < ActiveRecord::Migration
  def change
    add_column :polls, :rating_second_text, :string
  end
end
