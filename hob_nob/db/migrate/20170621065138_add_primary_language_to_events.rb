class AddPrimaryLanguageToEvents < ActiveRecord::Migration
  def change
  	add_column :events, :primary_language, :string
  end
end
