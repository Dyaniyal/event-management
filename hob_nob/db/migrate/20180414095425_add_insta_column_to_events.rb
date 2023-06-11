class AddInstaColumnToEvents < ActiveRecord::Migration
  def change
  	add_column :events, :instagram_secret_token, :string
  end
end
