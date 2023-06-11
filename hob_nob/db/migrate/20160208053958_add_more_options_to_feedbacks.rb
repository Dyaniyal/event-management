class AddMoreOptionsToFeedbacks < ActiveRecord::Migration
  def change
    add_column :feedbacks, :option6, :string
    add_column :feedbacks, :option7, :string
    add_column :feedbacks, :option8, :string
    add_column :feedbacks, :option9, :string
    add_column :feedbacks, :option10, :string
  end
end
