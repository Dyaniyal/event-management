class AddCommentBoxToMyTravels < ActiveRecord::Migration
  def change
  	add_column :my_travels, :comment_box, :string
  end
end
